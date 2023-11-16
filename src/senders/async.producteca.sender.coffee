_ = require("lodash")
OAuthApi = require("../services/oAuthApi")
NotificationsApi = require("../processors/job/notification.api")
Promise = require("bluebird")
retry = require("bluebird-retry")
uuid = require("uuid/v4")

notificationsApi = new NotificationsApi { }

_companyIdFromBasicToken = (token) =>
  decoded = Buffer.from(token, "base64").toString()
  _.split(decoded, ":")[0]

_companyId = (method, token) =>
  if (method != "Basic")
    return new OAuthApi(token).scopes().get("companyId")
  _companyIdFromBasicToken(token)

_headerValue = (headers, key, defaultValue) => 
  header = _.find(headers, { Key: key })
  _.get(header, "Value", defaultValue)

module.exports =
  user: ({ message: { HeadersForRequest } }) => 
    [method, token] = _headerValue(HeadersForRequest, "Authorization", "").split(" ")
    
    _companyId method, token

  resource: ({ message }, resourceGetter) => 
    if _.isFunction resourceGetter then resourceGetter message else _.get message, "Resource"
  
  monitoringCenterFields: (notification) ->
    fullToken = _headerValue(notification.message.HeadersForRequest, "Authorization", "")
    [method, token] = fullToken.split(" ")
    __scopes = () =>
      return retry(() => new OAuthApi(token).scopes()) if _(method.toLowerCase()).includes("bearer")
      Promise.resolve { id: null, appId: null, companyId: _companyIdFromBasicToken(token) }

    __job = () => 
      if notification.message.JobId and fullToken
        notificationsApi.fetchJob(notification.message.JobId, fullToken)
        .catchReturn()
        .then (it) => it or {} 
      else 
        Promise.resolve {}

    Promise.props {
      scopes: __scopes(),
      job: __job(),
    }
    .then ({ scopes: { id, companyId, appId }, job: { name, creationDate } }) =>
      eventId = notification.message.JobId or _headerValue(notification.message.HeadersForRequest, "x-producteca-event-id", null) or _headerValue(notification.message.HeadersForRequest, "X-producteca-event-id", null) or notification?.meta?.messageId or uuid()
      jobCreationDate = new Date(creationDate).getTime() if creationDate
      messageInsertionTime = new Date(notification?.meta?.insertionTime).getTime() if notification?.meta?.insertionTime 
      headersWithoutAuth = _.reject notification.message.HeadersForRequest, ({ Key }) => Key?.toLowerCase() is 'authorization'

      Promise.props { 
        eventType: 'http'
        resource: @resource(notification)
        companyId: companyId
        userId: id
        app: parseInt appId
        job: name
        externalReference: null
        eventId: eventId 
        eventTimestamp: jobCreationDate or messageInsertionTime
        parentEventId: null
        partialMessage: _.assign { }, notification.message, { HeadersForRequest: headersWithoutAuth }
      }

_ = require("lodash");
OAuthApi = require("../services/oAuthApi");
Promise = require("bluebird")
uuid = require("uuid/v4")

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
    console.log("el this async", @)
    __scopes = () =>
      [method, token] = _headerValue(notification.message.HeadersForRequest, "Authorization", "").split(" ")
      return new OAuthApi(token).scopes() if _(method.toLowerCase()).includes("bearer")
      Promise.resolve { id: null, appId: null, companyId: _companyIdFromBasicToken(token) }

    __scopes()
    .then ({ id, companyId, appId }) =>
      eventId = _headerValue(notification.message.HeadersForRequest, "x-producteca-event-id", null) or _headerValue(notification.message.HeadersForRequest, "X-producteca-event-id", null) or uuid()
      Promise.props { 
        eventType: 'http'
        resource: @resource(notification)
        companyId: companyId
        userId: id
        app: parseInt appId
        externalReference: null
        eventId: eventId #TODO: Sacar el id de la meta del mensaje? 
        eventTimestamp: new Date(notification?.meta?.insertionTime).getTime() if notification?.meta?.insertionTime #TODO: No es exactamente el timestamp del evento? es el de cuando llega a la cola de async...
        parentEventId: null
      }

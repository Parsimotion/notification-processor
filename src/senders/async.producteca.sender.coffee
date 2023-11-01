_ = require("lodash");
OAuthApi = require("../services/oAuthApi");
Promise = require("bluebird")

_companyId = (method, token) =>
  if (method != "Basic")
    return new OAuthApi(token).companyId()
  decoded = Buffer.from(token, "base64").toString()
  _.split(decoded, ":")[0]

_headerValue = (headers, key, defaultValue) => 
  header = _.find(headers, { Key: key })
  _.get(header, "Value", defaultValue)

module.exports =
  user: ({ message: { HeadersForRequest } }) => 
    [method, token] = _headerValue(HeadersForRequest, "Authorization", "").split(" ")
    
    _companyId method, token
  ,
  resource: ({ message }, resourceGetter) => 
    if _.isFunction resourceGetter then resourceGetter message else _.get message, "Resource"
  
  monitoringCenterFields: (notification) ->
    eventId = _headerValue(notification.message.HeadersForRequest, "x-producteca-event-id", null) or _headerValue(notification.message.HeadersForRequest, "X-producteca-event-id", null)
    Promise.props { 
      eventType: 'http'
      resource: @resource(notification)
      companyId: @user(notification)
      userId: null
      externalReference: null
      userExternalReference: null
      eventId: eventId
      eventTimestamp: new Date(notification?.meta?.insertionTime).getTime() if notification?.meta?.insertionTime #TODO: No es exactamente el timestamp del evento? es el de cuando llega a la cola de async...
      parentEventId: null
    }

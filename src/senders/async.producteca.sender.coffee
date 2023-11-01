_ = require("lodash");
OAuthApi = require("../services/oAuthApi");
Promise = require("bluebird")

_companyId = (method, token) =>
  if (method != "Basic")
    return new OAuthApi(token).companyId()
  decoded = Buffer.from(token, "base64").toString()
  _.split(decoded, ":")[0]


module.exports =
  user: ({ message: { HeadersForRequest } }) => 
    auth = _.find(HeadersForRequest, { Key: "Authorization" })
    [method, token] = _.get(auth, "Value", "").split(" ")
    
    _companyId method, token
  ,
  resource: ({ message }, resourceGetter) => 
    if _.isFunction resourceGetter then resourceGetter message else _.get message, "Resource"
  
  monitoringCenterFields: (notification) ->
    { Value: eventId } = _.find(notification.message.HeadersForRequest, (header) => header.Key is "x-producteca-event-id" or header.Key is "X-producteca-event-id" }) or {}
    Promise.props { 
      eventType: 'http'
      resource: @resource(notification)
      companyId: @user(notification)
      userId: null
      externalReference: null
      userExternalReference: null
      eventId: eventId
      eventTimestamp: new Date(notification?.meta?.insertionTime).getTime() if notification?.meta?.insertionTime
      parentEventId: null
    }

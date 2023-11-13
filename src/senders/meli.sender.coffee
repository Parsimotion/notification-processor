uuid = require "uuid/v4"
Promise = require "bluebird"
UserIdTranslator = require "../services/userIdTranslator"
module.exports =
  user: ({ message: { user_id } }) -> user_id
  resource: ({ message: { resource } }) -> resource
  monitoringCenterFields: (notification) ->
    new UserIdTranslator().translate(@user(notification))
    .then ({ app, companyId }) =>
      Promise.props { 
        eventType: 'http'
        resource: null
        app 
        companyId
        userId: null
        externalReference: @resource(notification)
        eventId: notification?.message?._id or uuid()
        eventTimestamp: new Date(notification?.meta?.insertionTime).getTime() if notification?.meta?.insertionTime
        parentEventId: null
      }

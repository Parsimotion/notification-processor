uuid = require "uuid/v4"
Promise = require "bluebird"
UserIdTranslator = require "../services/userIdTranlator"
module.exports =
  user: ({ message: { user_id } }) -> user_id
  resource: ({ message: { resource } }) -> resource
  monitoringCenterFields: (notification) ->
    Promise.props { 
      eventType: 'http'
      resource: null
      companyId: new UserIdTranslator().translate(@user(notification))
      userId: null
      externalReference: @resource(notification)
      eventId: notification?.message?._id or uuid()
      eventTimestamp: new Date(notification?.meta?.insertionTime).getTime() if notification?.meta?.insertionTime
      parentEventId: null
    }

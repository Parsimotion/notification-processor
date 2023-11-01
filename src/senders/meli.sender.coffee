uuid = require "uuid/v4"
Promise = require "bluebird"
module.exports =
  user: ({ message: { user_id } }) -> user_id
  resource: ({ message: { resource } }) -> resource
  monitoringCenterFields: (notification) ->
    Promise.props { 
      eventType: 'http'
      resource: null
      companyId: null
      userId: null
      externalReference: @resource(notification)
      userExternalReference: @user(notification)
      eventId: uuid()
      eventTimestamp: new Date(notification?.meta?.insertionTime).getTime() if notification?.meta?.insertionTime
      parentEventId: null
    }

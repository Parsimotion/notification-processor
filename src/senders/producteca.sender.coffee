Promise = require("bluebird")
module.exports =
  user: ({ message: { CompanyId } }) -> CompanyId
  resource: ({ message: { ResourceId } }) -> ResourceId
  monitoringCenterFields: (notification) ->
    Promise.props { 
      eventType: 'service-bus'
      resource: @resource(notification)
      companyId: @user(notification)
      userId: notification?.message?.UserId or notification?.message?.User
      externalReference: null
      userExternalReference: null
      eventId: notification?.message?.EventId
      eventTimestamp: new Date(notification?.message?.Sent).getTime() if notification?.message?.Sent
      parentEventId: notification?.message?.ParentEventId
    }

_ = require "lodash"
{ ServiceBusClient } = require("@azure/service-bus")
{ encode } = require "url-safe-base64"
debug = require("debug") "notification-processor:observers:incidents-api"

module.exports = 
  class IncidentsApiObserver

    constructor: ({ @sender, @clientId, @app, @job, @propertiesToOmit = "auth", connection : { connectionString, topic } }) ->
      @messageSender = @_buildMessageSender connectionString, topic
  
    listenTo: (observable) ->
      observable.on "unsuccessful_non_retriable", @publishToTopic

    publishToTopic: ({ id, notification, error }) =>
      message = { body: JSON.stringify @_mapper(id, notification, error.cause) }
      debug "To publish message %o", message
      @messageSender.send(message)

    _mapper: (id, notification, err) ->
      resource = @sender.resource notification
      
      {
        id: encode [@app, @job, resource].join("_")
        @app
        @job
        resource: "#{ resource }"
        notification: notification
        user: "#{ @sender.user(notification) }"
        @clientId
        error: _.omit err, "detail.request"
        request: _.omit _.get(err, "detail.request"), @propertiesToOmit
        type: _.get(err, "type") || "unknown_error"
      }
    
    _buildMessageSender: (connectionString, topic) ->
      ServiceBusClient
      .createFromConnectionString(connectionString)
      .createQueueClient(topic)
      .createSender()

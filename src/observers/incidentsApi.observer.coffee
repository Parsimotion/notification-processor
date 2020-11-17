_ = require "lodash"
Promise = require "bluebird"
{ ServiceBusClient } = require("@azure/service-bus")
{ encode } = require "url-safe-base64"
debug = require("debug") "notification-processor:observers:incidents-api"

module.exports = 
  class IncidentsApiObserver

    constructor: ({ @sender, @clientId, @app, @job, @propertiesToOmit = "auth", connection : { connectionString, topic } }) ->
      @messageSender = @_buildMessageSender connectionString, topic
  
    listenTo: (observable) ->
      observable.on "unsuccessful_non_retryable", @publishToTopic

    publishToTopic: ({ id, notification, error }) =>
      $message = Promise.props { body: JSON.stringify @_mapper(id, notification, error.cause) }
      $message
      .tap (message) => debug "To publish message %o", message
      .then (message) => @messageSender.send message

    _mapper: (id, notification, err) ->

      Promise.promisifyAll @sender

      __stringifySenderResult = (asyncFn) =>
        asyncFn notification
          .then (result) => "#{ result }"

      Promise.props      
        {
          id: encode [@app, @job, resource].join("_")
          @app
          @job
          resource: __stringifySenderResult @sender.resourceAsync
          notification: notification
          user: __stringifySenderResult @sender.user
          @clientId
          error: _.omit err, "detail.request"
          request: _.omit _.get(err, "detail.request"), @propertiesToOmit
          type: _.get err, "type", "unknown_error"
          tags: _.get err, "tags", []
        }
    
    _buildMessageSender: (connectionString, topic) ->
      ServiceBusClient
      .createFromConnectionString(connectionString)
      .createQueueClient(topic)
      .createSender()

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
      console.log "PUBLISH"
      $message = Promise.props { body: @_mapper(id, notification, error.cause) }
      console.log("LEL")
      $message
      .tap (message) => console.log("EE", message) or debug "To publish message %o", message
      .then (message) => @messageSender.send JSON.stringify message

    _mapper: (id, notification, err) ->
      console.log("MAPPER2")
      Promise.promisifyAll @sender

      Promise.props
        resource: @sender.resourceAsync notification
        user: @sender.userAsync notification
      .catch(console.log)
      .then ({ resource, user }) => console.log("OO") or {
        id: encode [@app, @job, resource].join("_")
        @app
        @job
        resource: "#{ resource }"
        notification: notification
        user: "#{ user }"
        @clientId
        error: _.omit err, "detail.request"
        request: _.omit _.get(err, "detail.request"), @propertiesToOmit
        type: _.get err, "type", "unknown_error"
        tags: _.get err, "tags", []
      }
      .tapCatch (it) => console.log("UU", it)
      .tap (it) => console.log("EEEEFG", it)
    
    _buildMessageSender: (connectionString, topic) ->
      ServiceBusClient
      .createFromConnectionString(connectionString)
      .createQueueClient(topic)
      .createSender()

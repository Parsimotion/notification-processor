_ = require "lodash"
Promise = require "bluebird"
retry = require "bluebird-retry"
debug = require("debug") "notification-processor:observers:monitor-center"
AWS = require "aws-sdk"
moment = require "moment"

module.exports = 
  class MonitoringCenterObserver

    constructor: ({ @sender, @clientId, @app, @job, @propertiesToOmit = "auth", connection : { accessKeyId, secretAccessKey, @deliveryStream, region } }) ->
      @firehose = new AWS.Firehose { accessKeyId, secretAccessKey, region }
      @uploadToFirehose = Promise.promisify(@firehose.putRecord).bind(@firehose)
    
    listenTo: (observable) ->
      observable.on "unsuccessful_non_retryable", (payload) => @uploadTrackingFile(payload, "unsuccessful_non_retryable")
      observable.on "unsuccessful", (payload) => @uploadTrackingFile(payload, "unsuccessful")
      observable.on "started", (payload) => @uploadTrackingFile(payload, "pending")
      observable.on "successful", (payload) => @uploadTrackingFile(payload, "successful")

    uploadTrackingFile: ({ id, notification, error }, eventType) =>
      @_mapper id, notification, error, eventType
      .then (record) => 
        return if _.isEmpty(record)

        uploadParams = {
          DeliveryStreamName: @deliveryStream, 
          Record: Data: JSON.stringify(record)
        }
        debug "Uploading file #{record.event} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        __uploadToFirehose = () => @uploadToFirehose uploadParams
        retry __uploadToFirehose, { throw_original: true }
        .tap () => debug "Uploaded file #{record.event} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        .catch (e) => # We'll do nothing with this error
          debug "Error uploading file #{record.event} to firehose delivery stream #{uploadParams.DeliveryStreamName} %o", e  
    
    _mapper: (id, notification, err, eventType) ->
      return Promise.resolve({ }) if !notification?.message?.EventId
      theRequest = _.get(err, "detail.request") || _.get(err, "cause.detail.request")
      Promise.props
        resource: Promise.method(@sender.resource) notification
        user: Promise.method(@sender.user) notification
      .then ({ resource, user }) => 
        now = new Date()
        messageDate = new Date(notification?.message?.Sent).getTime() if notification?.message?.Sent
        {
          id
          executionId: id
          app: parseInt @clientId
          type: "service-bus"
          company: "#{ user }" 
          user: null #TODO: Chequear si podemos completar esto
          event: notification?.message?.EventId,
          parent: notification?.message?.ParentEventId or null,
          externalreference: null
          timestamp: now.getTime()
          date: now.toISOString()
          year: moment(now).format('YYYY')
          month: moment(now).format('MM')
          day: moment(now).format('DD')
          hour: moment(now).format('HH')
          payload: JSON.stringify({
            @clientId
            @job
            @app
            error: _.omit(err, ["detail.request", "cause.detail.request"])
            request: _.omit(theRequest, _.castArray(@propertiesToOmit).concat("auth"))
            type: _.get err, "type", "unknown_error"
            tags: _.get err, "tags", []
          })
          status: eventType
          resource
          integration: "#{@app}|#{@job}"
          # Generic app fields
          event_timestamp: messageDate or now.getTime()
          output_message: _.get(err, "type")
          user_settings_version: null #TODO
          env_version: null #TODO
          code_version: null #TODO
        }



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

    uploadTrackingFile: ({ id, notification, error }, executionStatus) =>
      @_mapper id, notification, error, executionStatus
      .then (record) => 
        return if _.isEmpty(record)

        uploadParams = {
          DeliveryStreamName: @deliveryStream, 
          Record: Data: JSON.stringify(record)
        }
        debug "Uploading file #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        __uploadToFirehose = () => @uploadToFirehose uploadParams
        retry __uploadToFirehose, { throw_original: true }
        .tap () => debug "Uploaded file #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        .catch (e) => # We'll do nothing with this error
          debug "Error uploading file #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName} %o", e  
    _mapper: (id, notification, err, executionStatus) ->
      Promise.method(@sender.monitoringCenterFields.bind(@sender))(notification)
      .then ({ eventType, resource, companyId, userId, externalReference, userExternalReference, eventId, eventTimestamp, parentEventId, app, job, partialMessage }) => 
        return Promise.resolve({ }) if !eventId
        theRequest = _.get(err, "detail.request") || _.get(err, "cause.detail.request")

        errorDescription = 
          err and 
            _(["cause.message", "message", "cause.type", "type"])
            .map (property) => _.get err, property
            .reject _.isEmpty
            .get 0, "unknown"
        
        now = new Date()
        {
          id
          executionId: id
          app: app or parseInt(@clientId) or null
          type: eventType or "service-bus"
          company: companyId 
          user: userId
          event: eventId,
          parent: parentEventId,
          externalreference: externalReference
          userexternalreference: userExternalReference
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
            type: errorDescription
            tags: _.get err, "tags", []
            message: partialMessage or notification.message
          })
          status: executionStatus
          resource
          integration: "#{@app}|#{job or @job}"
          # Generic app fields
          event_timestamp: eventTimestamp or now.getTime()
          output_message: errorDescription
          user_settings_version: null #TODO
          env_version: null #TODO
          code_version: null #TODO
        }



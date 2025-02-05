_ = require "lodash"
Promise = require "bluebird"
retry = require "bluebird-retry"
debug = require("debug") "notification-processor:observers:monitor-center"
AWS = require "aws-sdk"
moment = require "moment"

TYPE_PROPERTIES = ["cause.type", "type"]
MESSAGE_PROPERTIES = ["cause.message", "message"]

module.exports = 
  class MonitoringCenterObserver

    constructor: ({ @sender, @clientId, @app, @job, @propertiesToOmit = "auth", connection : { accessKeyId, secretAccessKey, @deliveryStream, region } }) ->
      @firehose = new AWS.Firehose { accessKeyId, secretAccessKey, region }
      @uploadToFirehose = Promise.promisify(@firehose.putRecord).bind(@firehose)
    
    listenTo: (observable) ->
      observable.on "unsuccessful_non_retryable", (payload) => @registerRecord(payload, "unsuccessful")
      observable.on "unsuccessful", (payload) => @registerRecord(payload, "unsuccessful")
      observable.on "started", (payload) => @registerRecord(payload, "pending")
      observable.on "successful", (payload) => @registerRecord(payload, "successful")

    registerRecord: (payload, executionStatus) =>
      @_mapper _.merge({ executionStatus }, payload)
      .tap (record) => debug "Record to save in firehose %s %j", @deliveryStream, record
      .then (record) => 
        return if _.isEmpty(record)

        uploadParams = {
          DeliveryStreamName: @deliveryStream, 
          Record: Data: JSON.stringify(record)
        }
        debug "Uploading record #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        __uploadToFirehose = () => @uploadToFirehose uploadParams
        retry __uploadToFirehose, { throw_original: true }
        .tap () => debug "Uploaded record #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        .catch (e) => # We'll do nothing with this error
          debug "Error uploading record #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName} %o", e
    
    _mapper: ({ id, notification, error, warnings, executionStatus }) ->
      Promise.method(@sender.monitoringCenterFields.bind(@sender))(notification)
      .then ({ eventType, resource, companyId, userId, externalReference, userExternalReference, eventId, eventTimestamp, parentEventId, app, job, partialMessage }) => 
        return Promise.resolve({ }) if !eventId
        theRequest = _.get(error, "detail.request") or _.get(error, "cause.detail.request")

        errorType = @_retrieveMessageFromError error, TYPE_PROPERTIES, "unknown"
        errorMessage = @_retrieveMessageFromError error, MESSAGE_PROPERTIES, ""

        errorType = "timed_out" if /the operation did not complete within the allocated time/gi.test(errorType)
        
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
            error: _.omit(error, ["detail.request", "cause.detail.request"])
            request: _.omit(theRequest, _.castArray(@propertiesToOmit).concat("auth"))
            tags: _.get error, "tags", []
            message: partialMessage or notification.message
          })
          status: executionStatus
          resource
          integration: "#{@app}|#{job or @job}"
          # Generic app fields
          event_timestamp: eventTimestamp or now.getTime()
          error_type: errorType
          output_message: errorMessage
          user_settings_version: null #TODO
          env_version: null #TODO
          code_version: null #TODO
          warnings: warnings?.map (warning) => 
            {
              type: @_retrieveMessageFromError warning, TYPE_PROPERTIES, "unknown"
              message: @_retrieveMessageFromError warning, MESSAGE_PROPERTIES, ""
            }
        }

    _retrieveMessageFromError: (error, properties, defaultValue) -> 
      error and _(properties).map (property) => _.get error, property
        .reject _.isEmpty
        .get 0, defaultValue


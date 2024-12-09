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

    constructor: ({ @sender, @clientId, @app, @job, @propertiesToOmit = "auth", connection : { accessKeyId, secretAccessKey, @deliveryStream, @jobsDeliveryStream, region } }) ->
      @firehose = new AWS.Firehose { accessKeyId, secretAccessKey, region }
      @uploadToFirehose = Promise.promisify(@firehose.putRecord).bind(@firehose)
    
    listenTo: (observable) ->
      observable.on "unsuccessful_non_retryable", (payload) => @registerRecord(payload, "unsuccessful")
      observable.on "unsuccessful", (payload) => @registerRecord(payload, "unsuccessful")
      observable.on "started", (payload) => @registerRecord(payload, "pending")
      observable.on "successful", (payload) => @registerRecord(payload, "successful")

    registerRecord: (payload, executionStatus) =>
      jobId = _.get(payload, 'notification.message.JobId');
      deliveryStreamName = if jobId then @jobsDeliveryStream else @deliveryStream

      @_mapper _.merge({ executionStatus, jobId }, payload)
      .tap (record) => debug "Record to save in firehose %s %j", deliveryStreamName, record
      .then (record) => 
        return if _.isEmpty(record)

        uploadParams = {
          DeliveryStreamName: deliveryStreamName, 
          Record: Data: JSON.stringify(record)
        }
        debug "Uploading record #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        __uploadToFirehose = () => @uploadToFirehose uploadParams
        retry __uploadToFirehose, { throw_original: true }
        .tap () => debug "Uploaded record #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName}"
        .catch (e) => # We'll do nothing with this error
          debug "Error uploading record #{record.event}/#{record.id} to firehose delivery stream #{uploadParams.DeliveryStreamName} %o", e
    
    _mapper: ({ id, notification, error, warnings, executionStatus, jobId }) ->
      Promise.method(@sender.monitoringCenterFields.bind(@sender))(notification)
      .then ({ eventType, resource, companyId, userId, externalReference, userExternalReference, eventId, eventTimestamp, parentEventId, app, job, partialMessage }) => 
        return Promise.resolve({ }) if !eventId
        theRequest = _.get(error, "detail.request") or _.get(error, "cause.detail.request")

        errorType = @_retrieveMessageFromError error, TYPE_PROPERTIES, "unknown"

        errorType = "timed_out" if /the operation did not complete within the allocated time/gi.test(errorType)
        
        now = new Date()

        basicRegister = { id, app, companyId, now, executionStatus, errorType, job }

        executionRegister = { eventType, userId, eventId, parentEventId, externalReference, userExternalReference, error, theRequest, partialMessage, notification, resource, eventTimestamp, warnings }

        return if jobId then @_registerJob(basicRegister, jobId) else @_registerExecution(basicRegister, executionRegister)
      
    _registerJob: (basicRegister, jobId) =>
      {
        id: basicRegister.id,
        app: basicRegister.app or parseInt(@clientId) or null,
        trigger_id: jobId,
        trigger_mode: "scheduled",
        company: basicRegister.companyId,
        start_time: basicRegister.now.getTime(),
        integration: "#{@app}|#{basicRegister.job or @job}",
        error_type: basicRegister.errorType,
        status: basicRegister.executionStatus
      } 

    _registerExecution: (basicRegister, executionRegister) =>
      now = basicRegister.now
      errorMessage = @_retrieveMessageFromError executionRegister.error, MESSAGE_PROPERTIES, ""

      {
        id: basicRegister.id,
        executionId: basicRegister.id,
        app: basicRegister.app or parseInt(@clientId) or null,
        type: executionRegister.eventType or "service-bus",
        company: basicRegister.companyId,
        user: executionRegister.userId,
        event: executionRegister.eventId,
        parent: executionRegister.parentEventId,
        externalreference: executionRegister.externalReference
        userexternalreference: executionRegister.userExternalReference
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
          error: _.omit(executionRegister.error, ["detail.request", "cause.detail.request"])
          request: _.omit(executionRegister.theRequest, _.castArray(@propertiesToOmit).concat("auth"))
          tags: _.get executionRegister.error, "tags", []
          message: executionRegister.partialMessage or executionRegister.notification.message
        })
        status: basicRegister.executionStatus,
        resource: executionRegister.resource,
        integration: "#{@app}|#{basicRegister.job or @job}",
        # Generic app fields
        event_timestamp: executionRegister.eventTimestamp or now.getTime(),
        error_type: basicRegister.errorType,
        output_message: errorMessage,
        user_settings_version: null, #TODO
        env_version: null, #TODO
        code_version: null, #TODO
        warnings: executionRegister.warnings?.map (warning) => 
          {
            type: @_retrieveMessageFromError warning, TYPE_PROPERTIES, "unknown"
            message: @_retrieveMessageFromError warning, MESSAGE_PROPERTIES, ""
          }
      }

    _retrieveMessageFromError: (error, properties, defaultValue) -> 
      error and _(properties).map (property) => _.get error, property
        .reject _.isEmpty
        .get 0, defaultValue


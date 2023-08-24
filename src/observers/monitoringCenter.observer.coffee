_ = require "lodash"
Promise = require "bluebird"
retry = require "bluebird-retry"
debug = require("debug") "notification-processor:observers:monitor-center"
AWS = require "aws-sdk"

module.exports = 
  class MonitoringCenterObserver

    constructor: ({ @sender, @clientId, @app, @job, @propertiesToOmit = "auth", connection : { accessKeyId, secretAccessKey, monitoringCenterBucket, region } }) ->
      @s3 = new AWS.S3 { accessKeyId, secretAccessKey, region }
      @bucket = monitoringCenterBucket
      @uploadToS3 = Promise.promisify(@s3.upload).bind(@s3)
    
    listenTo: (observable) ->
      observable.on "unsuccessful_non_retryable", (payload) => @uploadTrackingFile(payload, "unsuccessful_non_retryable")
      observable.on "unsuccessful", (payload) => @uploadTrackingFile(payload, "unsuccessful")
      observable.on "started", (payload) => @uploadTrackingFile(payload, "started")
      observable.on "successful", (payload) => @uploadTrackingFile(payload, "successful")

    uploadTrackingFile: ({ id, notification, error }, eventType) =>
      @_mapper id, notification, error, eventType
      .then ({ key, body }) => 
        return if !key or !body
        uploadParams = {
          Bucket: @bucket, 
          Key: key, 
          Body: body
        }
        debug "Uploading file #{uploadParams.Key} to bucket #{uploadParams.Bucket}"
        __uploadToS3 = () => @uploadToS3 uploadParams
        retry __uploadToS3, { throw_original: true }
        .tap () => debug "Uploaded file #{uploadParams.Key} to bucket #{uploadParams.Bucket}"
        .catch (e) => # We'll do nothing with this error
          debug "Error uploading file #{uploadParams.Key} to bucket #{uploadParams.Bucket} %o", e
        
    
    _mapper: (id, notification, err, eventType) ->
      return Promise.resolve({ }) if !notification?.message?.EventId
      theRequest = _.get(err, "detail.request") || _.get(err, "cause.detail.request")
      Promise.props
        resource: Promise.method(@sender.resource) notification
        user: Promise.method(@sender.user) notification
      .then ({ resource, user }) => {
        key: "#{user}/#{notification.message.EventId}/#{id}/#{@app}|#{@job}|#{eventType}|#{new Date().toISOString()}"
        body: JSON.stringify {
          eventId: notification?.message?.EventId,
          parentEventId: notification?.message?.ParentEventId or null,
          executionId: id
          date: new Date().toISOString()
          resource: "#{ resource }"
          notification: notification
          user: "#{ user }"
          @clientId
          @jobId    
          @app
          error: _.omit(err, ["detail.request", "cause.detail.request"])
          request: _.omit(theRequest, _.castArray(@propertiesToOmit).concat("auth"))
          type: _.get err, "type", "unknown_error"
          tags: _.get err, "tags", []
        }
      }

   
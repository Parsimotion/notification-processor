_ = require "lodash"
Promise = require "bluebird"
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
      observable.on "finished", (payload) => @uploadTrackingFile(payload, "finished")
      observable.on "success", (payload) => @uploadTrackingFile(payload, "success")

    uploadTrackingFile: ({ id, notification, error }, eventType) =>
      @_mapper id, notification, error, eventType
      .then ({ key, body }) => 
        uploadParams = {
          Bucket: @bucket, 
          Key: key, 
          Body: body
        }
        debug "Uploading file #{uploadParams.Key} to bucket #{uploadParams.Bucket}"
        @uploadToS3 uploadParams
        .tap () => debug "Uploaded file #{uploadParams.Key} to bucket #{uploadParams.Bucket}"
        .tapCatch (e) => 
          debug "Error uploading file #{uploadParams.Key} to bucket #{uploadParams.Bucket} %o", e
        
    
    _mapper: (id, notification, err, eventType) ->
      Promise.props
        resource: Promise.method(@sender.resource) notification
        user: Promise.method(@sender.user) notification
      .then ({ resource, user }) => {
        key: "#{user}/#{notification.message.EventId}/#{eventType}"
        body: JSON.stringify {
          resource: "#{ resource }"
          notification: notification
          user: "#{ user }"
          @clientId
          error: _.omit err, "detail.request"
          request: _.omit _.get(err, "detail.request"), @propertiesToOmit
          type: _.get err, "type", "unknown_error"
          tags: _.get err, "tags", []
        }
      }

   
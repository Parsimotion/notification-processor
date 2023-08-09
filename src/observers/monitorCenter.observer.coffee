_ = require "lodash"
Promise = require "bluebird"
debug = require("debug") "notification-processor:observers:monitor-center"
AWS = require "aws-sdk"

module.exports = 
  class MonitorCenterObserver

    constructor: ({ @sender, @clientId, @app, @job, @propertiesToOmit = "auth", connection : { accessKey, secretAccessKey, @bucket } }) ->
      @s3 = new AWS.S3 { accessKeyId, secretAccessKey }
      @uploadToS3 = Promise.promisify(@s3.upload).bind(@s3)
    
    listenTo: (observable) ->
      observable.on "unsuccessful_non_retryable", (payload) => @uploadTrackingFile(payload, "unsuccessful_non_retryable")
      observable.on "unsuccessful", (payload) => @uploadTrackingFile(payload, "unsuccessful")
      observable.on "started", (payload) => @uploadTrackingFile(payload, "started")
      observable.on "finished", (payload) => @uploadTrackingFile(payload, "finished")
      observable.on "success", (payload) => @uploadTrackingFile(payload, "success")

    uploadTrackingFile: ({ id, notification, error }, eventType) =>
      { key, body } = @_mapper id, notification, error, eventType
      uploadParams = {
        Bucket: @bucket, 
        Key: key, 
        Body: body
      }
      
      debug "To upload file message %o", uploadParams
       @uploadToS3 uploadParams
      .tap () => debug "Uploaded file %o", uploadParams
      .tapCatch () => debug "Uploaded file %o", uploadParams
    
    _mapper: (id, notification, err, eventType) ->
      Promise.props
        resource: Promise.method(@sender.resource) notification
        user: Promise.method(@sender.user) notification
      .then ({ resource, user }) => {
        key: "#{user}_#{notification.meta.messageId}/#{eventType}"
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

   
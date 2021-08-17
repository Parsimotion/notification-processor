_ = require("lodash")
request = require("request-promise")
MaxRetriesProcessor = require("../maxRetries.processor")
NonRetryable = require("../../exceptions/non.retryable")
NotificationsApi = require("./notification.api")
debug = require("debug") "notification-processor:job-processor"

module.exports =
  class JobProcessor extends MaxRetriesProcessor

    constructor: (args) ->
      super args
      { @notificationApiUrl, @nonRetryable } = args

    process: (notification) =>
      @_ifJobIsNotStopped notification.message, () => super(notification).thenReturn()

    _onSuccess_: ({ message }, { statusCode }) =>
      @_ifJobIsNotStopped message, () => @_notificationsApi(message).success { message, statusCode }

    _shouldRetry_: (notification, err) =>
      super(notification, err) and err?.detail?.response?.statusCode not in @nonRetryable

    _sanitizeError_: (err) =>
      _.pick err, ["statusCode", "error"]

    _onMaxRetryExceeded_: ({ message }, error) =>
      errorMessage = {
        message
        statusCode: error.detail.response.statusCode
        error
        request: _.omit error.detail.request, ["resolveWithFullResponse"]
      }
      @_ifJobIsNotStopped message, () => 
        @_notificationsApi(message).fail errorMessage
          .throw new NonRetryable "Max retry exceeded", error

    _notificationsApi: ({ HeadersForRequest, JobId }) =>
      new NotificationsApi {
        token: _.find(HeadersForRequest, { Key: "Authorization" }).Value
        jobId: JobId
        @notificationApiUrl
      }

    _ifJobIsNotStopped: (message, action) =>
      @_notificationsApi(message).jobIsStopped()
      .then (jobIsStopped) =>
        if jobIsStopped
          console.log "job #{message.JobId} is stopped, ignoring action"
          return Promise.resolve() 
        action()

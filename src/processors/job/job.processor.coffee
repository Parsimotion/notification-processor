NotificationsApi = require("./notification.api")
MaxRetriesProcessor = require("../maxRetries.processor")
request = require("request-promise")
_ = require("lodash")

module.exports =
  class JobProcessor extends MaxRetriesProcessor

    constructor: (args) ->
      super args
      { @notificationApiUrl, @nonRetryable } = args

    process: (notification) ->
      super(notification).thenReturn()

    _onSuccess_: ({ message }, { statusCode }) =>
      @_notificationsApi(message).success { message, statusCode }

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

      @_notificationsApi(message).fail errorMessage
        .throw new NonRetryable "Max retry exceeded", err

    _notificationsApi: ({ HeadersForRequest, JobId }) =>
      new NotificationsApi {
        token: _.find(HeadersForRequest, { Key: "Authorization" }).Value
        jobId: JobId
        @notificationApiUrl
      }
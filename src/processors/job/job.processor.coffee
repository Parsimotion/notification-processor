NotificationsApi = require("./notification.api")
MaxRetriesProcessor = require("../maxRetries.processor")
request = require("request-promise")
_ = require("lodash")

module.exports =
  class JobProcessor extends MaxRetriesProcessor

    constructor: (args) ->
      super args
      @nonRetryable = args.nonRetryable

    process: (notification) ->
      super(notification).thenReturn()

    _onSuccess_: ({ message }, { statusCode }) =>
      @_notificationsApi(message).success { message, statusCode }

    _shouldRetry_: (notification, err) =>
      super(notification, err) and err?.detail?.response?.statusCode not in @nonRetryable

    _sanitizeError_: (err) =>
      _.pick err, ["statusCode", "error"]

    _onMaxRetryExceeded_: ({ message }, error) =>
      @_notificationsApi(message).fail {
        message
        statusCode: error.detail.response.statusCode
        error
        request: _.omit error.detail.request, ["resolveWithFullResponse"]
      }

    _notificationsApi: ({ headers }) =>
      new NotificationsApi headers["Authorization"]

IgnoredError = require "../exceptions/ignored.error"

module.exports =
  class MaxRetriesProcessor

    constructor: ({ @processor, @maxRetries = 3 }) ->

    process: (notification, context, executionId) ->
      @processor notification, context, executionId
      .tap (it) => @_onSuccess_ notification, it 
      .catch (err) =>
        return @_onIgnoredError_ notification, err if @_isIgnoredError_ err
        throw @_sanitizeError_ err if @_shouldRetry_ notification, err
        @_onMaxRetryExceeded_ notification, err

    _shouldRetry_: ({ meta: { dequeueCount = 0 } }, err) ->
      dequeueCount < @maxRetries

    _onSuccess_: (notification, result) -> throw new Error "subclass responsability"
    _sanitizeError_: (err) -> throw new Error "subclass responsability"
    _onMaxRetryExceeded_: (notification, err) -> throw new Error "subclass responsability"
    _onIgnoredError_: (notification, err) -> throw err
    _isIgnoredError_: (err) -> err instanceof IgnoredError

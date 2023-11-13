module.exports = 
  class MaxRetriesProcessor

    constructor: ({ @processor, @maxRetries = 3 }) ->

    process: (notification, context, executionId) ->
      @processor notification, context, executionId
      .tap (it) => @_onSuccess_ notification, it 
      .catch (err) =>
        throw @_sanitizeError_ err if @_shouldRetry_ notification, err
        @_onMaxRetryExceeded_ notification, err

    _shouldRetry_: ({ meta: { dequeueCount = 0 } }, err) ->
      dequeueCount < @maxRetries

    _onSuccess_: (notification, result) -> throw new Error "subclass responsability"
    _sanitizeError_: (err) -> throw new Error "subclass responsability"
    _onMaxRetryExceeded_: (notification, err) -> throw new Error "subclass responsability" 

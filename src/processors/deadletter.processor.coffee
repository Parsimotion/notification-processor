MaxRetriesProcessor = require "./maxRetries.processor"
NonRetryable = require "../exceptions/non.retryable"

module.exports =
  class DeadletterProcessor extends MaxRetriesProcessor
    _onSuccess_: (notification, result) ->
    _sanitizeError_: (err) -> err
    _onMaxRetryExceeded_: (notification, err) -> throw new NonRetryable { message: "Max retry exceeded", code: "max_retry_exceeded" }, err

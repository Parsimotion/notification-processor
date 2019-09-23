MaxRetriesProcessor = require "./maxRetries.processor"
NonRetryable = require "../exceptions/non.retryable"

module.exports =
  class DeadletterProcessor extends MaxRetriesProcessor
    _onSuccess_: (notification, result) ->
    _sanitizeError_: (err) -> err
    _onMaxRetryExceeded_: (notification, err) -> throw new NonRetryable "Max retry exceeded", err

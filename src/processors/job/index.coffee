_ = require("lodash")
JobProcessor = require "./job.processor"
RequestProcessor = require "../request.async.processor"

_normalizeHeaders = (headers) ->
  _(headers)
    .map ({ Key, Value }) -> [ Key, Value ]
    .fromPairs()
    .value()
    
module.exports = ({ apiUrl, notificationApiUrl, maxRetries, nonRetryable = [400] }) ->
  (it) -> 
  { HeadersForRequest } = it.message
  headers = _normalizeHeaders HeadersForRequest
  new JobProcessor {
    processor: RequestProcessor { apiUrl: headers.Domain || apiUrl, fullResponse: true }
    maxRetries
    nonRetryable
    notificationApiUrl
  }
  .process it

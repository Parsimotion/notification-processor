_ = require "lodash"
RequestProcessor = require "./request.processor"

_normalizeHeaders = (headers) ->
  _(headers)
    .map ({ Key, Value }) -> [ Key, Value ]
    .fromPairs()
    .value()

builderRequest = (apiUrl, fullResponse) -> ({ message }, context, executionId) ->
  { Resource, Method, Body, HeadersForRequest, JobId } = message
  json = if Body?.length > 0 then JSON.parse(Body) else true
  headers = _normalizeHeaders HeadersForRequest
  headers['x-producteca-event-id'] = "#{JobId}/#{executionId}" if JobId
  url = headers.Domain || apiUrl;

  return {
    url: "#{ url }#{ Resource }"
    method: Method
    headers: headers
    json: json
    resolveWithFullResponse: fullResponse
  }

module.exports = ({ apiUrl, fullResponse = false, silentErrors, nonRetryable }) ->
  RequestProcessor builderRequest(apiUrl, fullResponse), { silentErrors, nonRetryable }
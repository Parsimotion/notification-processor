_ = require "lodash"
RequestProcessor = require "./request.processor"

_normalizeHeaders = (headers) ->
  _(headers)
    .map ({ Key, Value }) -> [ Key, Value ]
    .fromPairs()
    .value()

builderRequest = (apiUrl, fullResponse) -> ({ message }) ->
  { Resource, Method, Body, HeadersForRequest } = message
  json = if Body?.length > 0 then JSON.parse(Body) else true

  headers = _normalizeHeaders HeadersForRequest

  url = headers.Domain || apiUrl;

  return {
    url: "#{ url }#{ Resource }"
    method: Method
    headers: headers
    json: json
    resolveWithFullResponse: fullResponse
  }

module.exports = ({ apiUrl, fullResponse = false }) ->
  RequestProcessor builderRequest(apiUrl, fullResponse)
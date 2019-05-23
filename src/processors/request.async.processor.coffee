_ = require "lodash"
RequestProcessor = require "./request.processor"

_normalizeHeaders = (headers) ->
  _(headers)
    .map ({ Key, Value }) -> [ Key, Value ]
    .fromPairs()
    .value()

builderRequest = (apiUrl) -> ({ message }) ->
  { Resource, Method, Body, HeadersForRequest } = message
  json = if Body?.length > 0 then JSON.parse(Body) else true

  return {
    url: "#{ apiUrl }#{ Resource }"
    method: Method
    headers: _normalizeHeaders HeadersForRequest
    json: json
  }

module.exports = ({ apiUrl, silentErrors }) ->
  RequestProcessor builderRequest(apiUrl), silentErrors
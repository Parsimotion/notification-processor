_ = require("lodash")
JobProcessor = require "./job.processor"
RequestProcessor = require "../request.processor"

MAX_DEQUEUE_COUNT = process.env.MAX_DEQUEUE_COUNT

_normalizeHeaders = (headers) ->
  _(headers)
    .map ({ Key, Value }) -> [ Key, Value ]
    .fromPairs()
    .value()

_normalizeMessage = ({ JobId, Resource, Method, Body, HeadersForRequest }) ->
  _.omitBy {
    method: Method
    body: Body
    resource: Resource
    headers: _normalizeHeaders HeadersForRequest
    jobId: JobId
  }, _.isUndefined

module.exports = ({ buildOpts, maxRetries, nonRetryable = [400] }) ->
  __buildOpts = (message) ->
    _.merge { resolveWithFullResponse: yes }, buildOpts(message)

  processor = RequestProcessor __buildOpts
  jobProcesor = new JobProcessor({ processor, maxRetries, nonRetryable })

  (it) ->
    _.update it, "message", _normalizeMessage
    jobProcesor.process it
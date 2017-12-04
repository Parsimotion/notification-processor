MAX_DEQUEUE_COUNT = process.env.MAX_DEQUEUE_COUNT

NotificationsApi = require("./notification.api")
request = require("request-promise")
_ = require("lodash")
notificationsApi = null

_getHeaders = (headers) ->
  _(headers)
    .map ({ Key, Value }) -> [ Key, Value ]
    .fromPairs()
    .value()

_cleanOptions = ({Resource, Method, Body, HeadersForRequest}) ->
  _.omitBy {
    method: Method
    body: Body
    resource: Resource
    headers: _getHeaders HeadersForRequest
  }, _.isUndefined

module.exports = (generateOptions, nonRetryable = [400]) -> ({ message, meta: { dequeueCount }}) ->
  messageOptions = _cleanOptions message
  notificationsApi = new NotificationsApi messageOptions.headers["Authorization"]
  options = _.merge {}, generateOptions(messageOptions), resolveWithFullResponse: yes

  request options
  .promise()
  .tap ({ statusCode }) -> notificationsApi.success { message, statusCode }
  .catch ({ statusCode, error }) ->
    throw { statusCode, error } unless dequeueCount >= MAX_DEQUEUE_COUNT or statusCode in nonRetryable
    notificationsApi.fail { message, statusCode, error, request: { options } }
  .thenReturn()

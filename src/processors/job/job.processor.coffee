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

_notifySuccess = ({ message: { JobId }, statusCode }) -> notificationsApi.success JobId, statusCode
_notifyFail = ({ message: { JobId }, statusCode, error }) -> notificationsApi.fail JobId, statusCode, error

module.exports = (generateOptions) -> ({ message, meta: { dequeueCount }}) ->
  messageOptions = _cleanOptions message
  notificationsApi = new NotificationsApi messageOptions.headers["Authorization"]
  options = _.merge {}, generateOptions(messageOptions), resolveWithFullResponse: yes

  request options
  .promise()
  .tap ({ statusCode }) -> _notifySuccess { message, statusCode }
  .catch ({ statusCode, error }) ->
    throw { statusCode, error } unless dequeueCount >= MAX_DEQUEUE_COUNT
    _notifyFail { message, statusCode, error }

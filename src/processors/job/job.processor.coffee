MAX_DEQUEUE_COUNT = process.env.MAX_DEQUEUE_COUNT

NotificationsApi = require("./notification.api")
request = require("request-promise")
Promise = require("bluebird")
_ = require("lodash")

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

module.exports = (generateOptions) -> ({ message, meta: { dequeueCount }}) ->
  messageOptions = _cleanOptions message
  notificationsApi = new NotificationsApi messageOptions.headers["Authorization"]
  options = _.merge {}, generateOptions(messageOptions), resolveWithFullResponse: yes

  request options
  .promise()
  .then ({ statusCode }) -> notificationsApi.success message.JobId, statusCode
  .catch ({ statusCode, error }) ->
    throw { statusCode, error } unless dequeueCount >= MAX_DEQUEUE_COUNT
    notificationsApi.fail message.JobId, statusCode, error
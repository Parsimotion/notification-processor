_ = require "lodash"
NonRetryableError = require "../exceptions/non.retryable"
Promise = require "bluebird";
request = require "request-promise"
{ StatusCodeError, RequestError } = require "request-promise/errors"

_safeParse = (raw) ->  if _.isObject(raw) then raw else try JSON.parse raw

errorConditions =
  client: (it) -> it >= 400 and it < 500
  server: (it) -> it >= 500

__isIncludedInStatusesError = (conditions) -> (err) ->
  statusCode = _.get err, "detail.response.statusCode"
  _(conditions)
  .map (it) -> _.get(errorConditions, it, _.partial(_.isEqual, it)) 
  .some (condition) -> condition statusCode

module.exports = (requestGenerator, { silentErrors = [], nonRetryable = [] } = {}) -> (notification) ->
  Promise.method(requestGenerator) notification
  .then (options) -> 
    request options
    .promise()
    .catch RequestError, ({ cause }) ->
      throw {
        type: cause.code
        detail: cause
      }
    .catch StatusCodeError, ({ statusCode, error }) ->
      safeError = _safeParse error

      throw {
        message: _.get(safeError, "error.message") or _.get(safeError, "message")
        detail: { response: { statusCode, body: safeError } }
        tags: safeError?.tags
      }
    .tapCatch (err) -> _.defaultsDeep err, { detail: { request: options } }
    .catch __isIncludedInStatusesError(silentErrors), (err) -> err
    .catch __isIncludedInStatusesError(nonRetryable), (err) -> throw new NonRetryableError "An error has ocurred in that request", _.omit(err, "response")
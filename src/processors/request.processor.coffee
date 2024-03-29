_ = require "lodash"
NonRetryableError = require "../exceptions/non.retryable"
IgnoredError = require "../exceptions/ignored.error"
Promise = require "bluebird";
request = require "request-promise"
{ StatusCodeError, RequestError } = require "request-promise/errors"
httpStatus = require("http").STATUS_CODES
MESSAGE_PROPERTIES = ["reason", "error.error", "error.code", "code", "error"]

_safeParse = (raw) ->  if _.isObject(raw) then raw else try JSON.parse raw

_type = (statusCode, error) ->
  _ MESSAGE_PROPERTIES
    .map (key) -> _.get error, key
    .concat [ _.toLower(httpStatus[statusCode]) ]
    .filter _.isString
    .compact()
    .head()

errorConditions =
  client: (it) -> it >= 400 and it < 500
  server: (it) -> it >= 500

__isIncludedInStatusesError = (conditions) -> (err) ->
  statusCode = _.get err, "detail.response.statusCode"
  _(conditions)
  .map (it) -> _.get(errorConditions, it, _.partial(_.isEqual, it)) 
  .some (condition) -> condition statusCode

module.exports = (requestGenerator, { silentErrors = [], nonRetryable = [] } = {}) -> (notification, context, executionId) ->
  Promise.method(requestGenerator) notification, context, executionId
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
      type = _type statusCode, safeError

      throw {
        type
        message: _.get(safeError, "error.message") or _.get(safeError, "message") or type
        detail: { response: { statusCode, body: safeError } }
        tags: safeError?.tags
      }
    .tapCatch (err) -> _.defaultsDeep err, { type: "unknown", message: "unknown", detail: { request: options } }
    .catch __isIncludedInStatusesError(silentErrors), (err) -> throw new IgnoredError "An error has ocurred in that request but should be ignored", _.omit(err, "response")
    .catch __isIncludedInStatusesError(nonRetryable), (err) -> throw new NonRetryableError "An error has ocurred in that request", _.omit(err, "response")
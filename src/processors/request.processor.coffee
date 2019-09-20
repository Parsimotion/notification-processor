_ = require "lodash"
NonRetryableError = require "../exceptions/non.retryable"
Promise = require "bluebird";
request = require "request-promise"
{ StatusCodeError, RequestError } = require "request-promise/errors"
httpStatus = require("http").STATUS_CODES
MESSAGE_PROPERTIES = ["reason", "error.error", "error.code", "code", "error"]

_safeParse = (raw) ->  if _.isObject(raw) then raw else try JSON.parse raw

_type = (statusCode, error) ->
  _ MESSAGE_PROPERTIES
    .map (key) -> _.get error, key
    .concat [ httpStatus[statusCode] ]
    .filter _.isString
    .compact()
    .head()

module.exports = (requestGenerator, { silentErrors = [], nonRetryable = [] } = {}) -> (notification) ->
  __isIncludedInStatusesError = (statuses) -> (err) ->
    err.constructor is StatusCodeError and _.includes statuses, err.statusCode

  Promise.method(requestGenerator) notification
  .then (options) -> 
    request options
    .promise()
    .catch __isIncludedInStatusesError(silentErrors), (err) -> _.omit err, "response"
    .catch __isIncludedInStatusesError(nonRetryable), (err) -> throw new NonRetryableError _.omit(err, "response")
    .catch StatusCodeError, ({ statusCode, error }) ->
      safeError = _safeParse error
      type = _type statusCode, safeError

      throw {
        type
        message: _.get(safeError, "error.message") or _.get(safeError, "message") or type
        detail: { response: { statusCode, body: safeError } }
      }
    .catch RequestError, ({ cause }) ->
      throw {
        type: cause.code
        detail: cause
      }
    .tapCatch (err) -> _.defaultsDeep err, { type: "unknown", message: "unknown", detail: { request: options } }
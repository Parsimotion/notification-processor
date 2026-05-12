_ = require "lodash"
NonRetryableError = require "../exceptions/non.retryable"
IgnoredError = require "../exceptions/ignored.error"
Promise = require "bluebird";
axios = require "axios"
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

_toAxiosOptions = (options) ->
  axiosOptions = {
    url: options.url
    method: options.method
    headers: options.headers
  }
  axiosOptions.params = options.qs if options.qs
  axiosOptions.data = options.json if options.json and options.json isnt true
  if options.auth
    axiosOptions.auth = { username: options.auth.user, password: options.auth.password }
  axiosOptions

module.exports = (requestGenerator, { silentErrors = [], nonRetryable = [] } = {}) -> (notification, context, executionId) ->
  Promise.method(requestGenerator) notification, context, executionId
  .then (options) ->
    axiosOptions = _toAxiosOptions options
    Promise.resolve(axios axiosOptions)
    .then (response) ->
      if options.resolveWithFullResponse
        { statusCode: response.status, body: response.data, headers: response.headers }
      else
        response.data
    .catch (err) ->
      if err.response
        statusCode = err.response.status
        error = err.response.data
        safeError = _safeParse error
        type = _type statusCode, safeError
        throw {
          type
          message: _.get(safeError, "error.message") or _.get(safeError, "message") or type
          detail: { response: { statusCode, body: safeError } }
          tags: safeError?.tags
        }
      else
        throw {
          type: err.code
          detail: err
        }
    .tapCatch (err) -> _.defaultsDeep err, { type: "unknown", message: "unknown", detail: { request: options } }
    .catch __isIncludedInStatusesError(silentErrors), (err) -> throw new IgnoredError "An error has ocurred in that request but should be ignored", _.omit(err, "response")
    .catch __isIncludedInStatusesError(nonRetryable), (err) -> throw new NonRetryableError "An error has ocurred in that request", _.omit(err, "response")

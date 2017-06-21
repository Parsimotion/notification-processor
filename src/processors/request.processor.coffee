_ = require "lodash"
request = require "request-promise"
{ StatusCodeError, RequestError } = require "request-promise/errors"
MESSAGE_PROPERTIES = ["reason", "error", "message"]

_retrieveMessage = (message) ->
  if _.isString(message) then message else null

_safeParse = (raw) -> try JSON.parse raw

module.exports = (requestGenerator, { silentErrors = [] } = {}) -> (notification) ->
  __isSilentError = (err) ->
    err.constructor is StatusCodeError and _.includes silentErrors, err.statusCode

  options = requestGenerator notification

  request options
  .promise()
  .catch __isSilentError, (err) -> _.omit err, "response"
  .catch StatusCodeError, ({ statusCode, error }) ->
    throw
      message: _(_safeParse error).pick(MESSAGE_PROPERTIES).values().map(_retrieveMessage).compact().head()
      detail: response: { statusCode, body: error }
  .catch RequestError, ({ cause }) ->
    throw
      message: cause.code
      detail: cause
  .tapCatch (err) -> _.defaultsDeep err, { message: "unknown", detail: request: options }
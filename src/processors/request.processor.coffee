_ = require "lodash"
request = require "request-promise"
{ StatusCodeError } = require "request-promise/errors"

module.exports = (requestGenerator, { silentErrors = [] } = {}) -> (notification) ->
  __isSilentError = (err) ->
    err.constructor is StatusCodeError and _.includes silentErrors, err.statusCode

  request requestGenerator notification
  .promise()
  .catch __isSilentError, (err) -> _.omit err, "response"

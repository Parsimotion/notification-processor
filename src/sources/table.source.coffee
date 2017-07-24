_ = require "lodash"

module.exports = (OtherSource) ->
  newNotification: ({ message: { notification } }) -> _.merge notification, { type: "table" }
  delayObserver: -> throw new Error "not supported `delayObserver`"
  deadLetterSucceeded: (opts) -> OtherSource.deadLetterSucceeded opts
  didLastRetry: -> throw new Error "not supported `didLastRetry`"

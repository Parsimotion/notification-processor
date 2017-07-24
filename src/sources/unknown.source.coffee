_ = require "lodash"

module.exports =
  newNotification: ({ message }) -> { message, type: "uk" }
  delayObserver: -> throw new Error "not supported `delayObserver`"
  deadLetterSucceeded: -> throw new Error "not supported `deadLetterSucceeded`"
  didLastRetry: -> throw new Error "not supported `didLastRetry`"

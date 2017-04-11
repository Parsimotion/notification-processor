_ = require "lodash"

module.exports =
  newNotification: ({ message }) -> { message, type: "uk" }
  shouldBeIgnore: -> false
  delayObserver: -> throw new Error "not supported `delayObserver`"

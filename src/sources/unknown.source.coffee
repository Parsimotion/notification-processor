_ = require "lodash"

module.exports =
  newNotification: ({ message }) -> { message, type: "uk" }
  shouldBeIgnore: -> false

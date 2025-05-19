_ = require "lodash"

module.exports = (OtherSource) ->
  newNotification: ({ message: { notification } }) -> _.merge notification, { type: "table" }

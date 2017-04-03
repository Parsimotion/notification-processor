_ = require "lodash"

module.exports = ({ message }) ->
  message: _.omit message, "Sent"
  meta: insertionTime: message.Sent

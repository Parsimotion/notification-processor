_ = require "lodash"

module.exports =
  newNotification: ({ context: { bindingData }, message }) ->
    message: _.omit message, "Sent"
    meta:
      messageId: bindingData.messageId
      insertionTime: bindingData.enqueuedTimeUtc
      dequeueCount: bindingData.deliveryCount
      properties: bindingData.userProperties or bindingData.properties
    type: "sb"

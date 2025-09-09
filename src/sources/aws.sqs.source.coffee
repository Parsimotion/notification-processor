_ = require "lodash"

module.exports =
  newNotification: ({ context, message }) ->
    message
    meta: { 
      insertionTime:  _.get(context, "bindingData.sentTimestamp"), 
      dequeueCount: _.get(context, "bindingData.approximateReceiveCount"),
      messageId:  _.get(context, "bindingData.id")
    }
    type: "sqs"
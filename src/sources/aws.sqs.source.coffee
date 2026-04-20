_ = require "lodash"

module.exports =
  newNotification: ({ context, message }) ->
    message: if(!_.isObject(message.Message)) then JSON.parse(message.Message) else message.Message
    meta: {
      insertionTime:  _.get(context, "bindingData.sentTimestamp"),
      dequeueCount: _.get(context, "bindingData.approximateReceiveCount"),
      messageId:  _.get(context, "bindingData.id")
    }
    type: "sqs"

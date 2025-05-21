_ = require "lodash"

module.exports = 
  newNotification: ({ context: { bindingData : { insertionTime, dequeueCount, messageId, Message, MessageId } }, message }) ->
    message: if(!_.isObject(message.Message)) then JSON.parse(message.Message) else message.Message
    meta: {
      insertionTime,
      dequeueCount,
      messageId: messageId or MessageId or Message
    }
    type: "sqs"
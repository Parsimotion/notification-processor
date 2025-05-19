module.exports = 
  newNotification: ({ context: { bindingData : { insertionTime, dequeueCount, messageId, Message, MessageId } }, message }) ->
    message: JSON.parse(message.Message)
    meta: {
      insertionTime,
      dequeueCount,
      messageId: messageId or MessageId or Message
    }
    type: "sqs"
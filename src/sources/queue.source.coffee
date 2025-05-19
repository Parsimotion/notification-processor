module.exports =
  newNotification: ({ context: { bindingData : { insertionTime, dequeueCount, messageId, Message, MessageId } }, message }) ->
    message: message
    meta: { 
      insertionTime, 
      dequeueCount,
      messageId: messageId or MessageId or Message
    }
    type: "as"

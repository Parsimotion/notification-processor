_ = require "lodash"

module.exports = 
  newNotification: ({ context, message }) ->
    message: if(!_.isObject(message.Message)) then JSON.parse(message.Message) else message.Message
    meta: {
      insertionTime: _.get(message, "Timestamp"),
      messageId: _.get(message, "MessageId"),
      properties: _.mapValues _.get(message, "MessageAttributes"), ({ Type, Value }) ->
        if _.includes(Type, 'Array')
          JSON.parse(Value)
        else if Type is 'Number'
          Number(Value)
        else
          Value
      dequeueCount: _.get(context, "bindingData.approximateReceiveCount")
    }
    type: "sqs"
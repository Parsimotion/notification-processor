_ = require "lodash"
DelayObserver = require "../observers/delay.observer"
DeadLetterSucceeded = require "../observers/deadLetterSucceeded.observer"
DidLastRetry = require "../observers/didLastRetry.observer"

create = (Type) -> (opts) ->
  { queue } = opts
  new Type _(opts).omit([ "queue" ]).defaults(path: "#{queue}").value()

module.exports =
  newNotification: ({ context: { bindingData : { insertionTime, dequeueCount, messageId, message, Message, MessageId } }, message }) ->
    message: message
    meta: { 
      insertionTime, 
      dequeueCount,
      messageId: messageId or MessageId or message or Message
    }
    type: "as"

  delayObserver: create DelayObserver
  deadLetterSucceeded: create DeadLetterSucceeded
  didLastRetry: create DidLastRetry

_ = require "lodash"
DelayObserver = require "../observers/delay.observer"
DeadLetterSucceeded = require "../observers/deadLetterSucceeded.observer"
DidLastRetry = require "../observers/didLastRetry.observer"

create = (Type) -> (opts) ->
  { topic, subscription } = opts
  new Type _(opts).omit([ "topic", "subscription" ]).defaults(path: "#{topic}/#{subscription}").value()


module.exports =
  newNotification: ({ context: { bindingData }, message }) ->
    message: _.omit message, "Sent" #TODO: whyyyyy
    meta:
      messageId: bindingData.messageId
      insertionTime: bindingData.enqueuedTimeUtc
      dequeueCount: bindingData.deliveryCount
      properties: bindingData.userProperties or bindingData.properties
    type: "sb"

  delayObserver: create DelayObserver

  deadLetterSucceeded: create DeadLetterSucceeded

  didLastRetry: create DidLastRetry


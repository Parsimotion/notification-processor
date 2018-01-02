_ = require "lodash"
DelayObserver = require "../observers/delay.observer"
DeadLetterSucceeded = require "../observers/deadLetterSucceeded.observer"
DidLastRetry = require "../observers/didLastRetry.observer"

create = (Type) -> (opts) ->
  { topic, subscription } = opts
  new Type _(opts).omit([ "topic", "subscription" ]).defaults(path: "#{topic}/#{subscription}").value()


module.exports =
  newNotification: ({ context: { bindingData : { enqueuedTimeUtc, deliveryCount, properties } }, message }) ->
    message: _.omit message, "Sent"
    meta:
      insertionTime: enqueuedTimeUtc
      dequeueCount: deliveryCount
      properties: properties
    type: "sb"

  delayObserver: create DelayObserver

  deadLetterSucceeded: create DeadLetterSucceeded

  didLastRetry: create DidLastRetry


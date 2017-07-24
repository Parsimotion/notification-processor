_ = require "lodash"
DelayObserver = require "../observers/delay.observer"
DeadLetterSucceeded = require "../observers/deadLetterSucceeded.observer"
DidLastRetry = require "../observers/didLastRetry.observer"

create = (Type) -> (opts) ->
  { queue } = opts
  new Type _(opts).omit([ "queue" ]).defaults(path: "#{queue}").value()

module.exports =
  newNotification: ({ context: { bindingData : { insertionTime, dequeueCount } }, message }) ->
    message: message
    meta: { insertionTime, dequeueCount }
    type: "as"

  delayObserver: create DelayObserver
  deadLetterSucceeded: create DeadLetterSucceeded
  didLastRetry: create DidLastRetry

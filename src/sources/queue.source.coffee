_ = require "lodash"
DelayObserver = require "../observers/delay.observer"
DeadLetterSucceeded = require "../observers/deadLetterSucceeded.observer"
DidLastRetry = require "../observers/didLastRetry.observer"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

create = (Type) -> ({ redis, app, queue }) ->
  new Type { redis, app, path: "#{queue}" }

module.exports =
  newNotification: ({ context: { bindingData : { insertionTime, dequeueCount } }, message }) ->
    message: message
    meta: { insertionTime, dequeueCount }
    type: "as"

  shouldBeIgnored: ({ notification }) ->
    _.includes IgnoredUsers, notification?.message?.user_id?.toString()

  delayObserver: create DelayObserver
  deadLetterSucceeded: create DeadLetterSucceeded
  didLastRetry: create DidLastRetry

_ = require "lodash"
DelayObserver = require "../observers/delay.observer"
DeadLetterSucceeded = require "../observers/deadLetterSucceeded.observer"
DidLastRetry = require "../observers/didLastRetry.observer"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

create = (Type) -> ({ redis, app, topic, subscription }) ->
  new Type { redis, app, path: "#{topic}/#{subscription}" }


module.exports =
  newNotification: ({ message }) ->
    message: _.omit message, "Sent"
    meta:
      insertionTime: message.Sent
      dequeueCount: 0
    type: "sb"

  shouldBeIgnored: ({ notification }) ->
    _.includes IgnoredUsers, notification?.message?.CompanyId?.toString()

  delayObserver: create DelayObserver

  deadLetterSucceeded: create DeadLetterSucceeded

  didLastRetry: create DidLastRetry


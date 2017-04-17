_ = require "lodash"
DelayObserver = require "../observers/delay.observer"
DeadLetterSucceeded = require "../observers/deadLetterSucceeded.observer"
DidLastRetry = require "../observers/didLastRetry.observer"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

module.exports =
  newNotification: ({ message }) ->
    message: _.omit message, "Sent"
    meta:
      insertionTime: message.Sent
      dequeueCount: 0
    type: "sb"

  shouldBeIgnored: ({ notification }) ->
    _.includes IgnoredUsers, notification?.message?.CompanyId?.toString()

  delayObserver: ({ redis, app, topic, subscription }) ->
    new DelayObserver { redis, app, path: "#{topic}/#{subscription}" }

  deadLetterSucceeded: ({ redis, app, topic, subscription }) ->
    new DeadLetterSucceeded { redis, app, path: "#{topic}/#{subscription}" }

  didLastRetry: ({ redis, app, topic, subscription }) ->
    new DidLastRetry { redis, app, path: "#{topic}/#{subscription}" }

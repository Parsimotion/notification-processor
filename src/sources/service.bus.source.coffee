_ = require "lodash"
DelayObserver = require "../observers/delay.observer"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

module.exports =
  newNotification: ({ message }) ->
    message: _.omit message, "Sent"
    meta: insertionTime: message.Sent
    type: "sb"

  shouldBeIgnore: ({ notification }) ->
    _.includes IgnoredUsers, notification?.message?.CompanyId?.toString()

  delayObserver: ({ redis, app, topic, subscription }) ->
    new DelayObserver { redis, app, path: "#{topic}/#{subscription}" }

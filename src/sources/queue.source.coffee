_ = require "lodash"
DelayObserver = require "../observers/delay.observer"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

module.exports =
  newNotification: ({ context: { bindingData : { insertionTime, dequeueCount } }, message }) ->
    message: message
    meta: { insertionTime, dequeueCount }
    type: "as"

  shouldBeIgnored: ({ notification }) ->
    _.includes IgnoredUsers, notification?.message?.user_id?.toString()

  delayObserver: ({ redis, app, queue }) ->
    new DelayObserver { redis, app, path: queue }

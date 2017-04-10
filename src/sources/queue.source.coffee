_ = require "lodash"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

module.exports =
  newNotification: ({ context: { bindingData : { insertionTime } }, message }) ->
    message: message
    meta: { insertionTime }

  shouldBeIgnore: ({ message: { user_id }}) ->
    _.includes IgnoredUsers, user_id?.toString()

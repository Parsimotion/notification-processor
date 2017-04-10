_ = require "lodash"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

module.exports =
  newNotification: ({ message }) ->
    message: _.omit message, "Sent"
    meta: insertionTime: message.Sent
    type: "sb"

  shouldBeIgnore: ({ message: { CompanyId }}) ->
    _.includes IgnoredUsers, CompanyId?.toString()

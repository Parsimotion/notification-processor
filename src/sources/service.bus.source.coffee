_ = require "lodash"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

module.exports =
  adapt: ({ message }) ->
    message: _.omit message, "Sent"
    meta: insertionTime: message.Sent

  shouldBeIgnore: ({ message: { CompanyId }}) ->
    _.includes IgnoredUsers, CompanyId?.toString()

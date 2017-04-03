_ = require "lodash"

MeliUsersThanNotBelongsToProducteca = process.env.MeliUsersThanNotBelongsToProducteca?.split(",") or []
MeliUsersThanCanNotRefreshAccessToken = process.env.MeliUsersThanCanNotRefreshAccessToken?.split(",") or []

IgnoredUsers = _.concat MeliUsersThanNotBelongsToProducteca, MeliUsersThanCanNotRefreshAccessToken

module.exports = ({ message: { CompanyId }}) ->
	_.includes IgnoredUsers, CompanyId.toString()

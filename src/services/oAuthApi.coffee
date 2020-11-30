request = require("request-promise");

OAUTH_API_URL = process.env.OAUTH_API_URL or "https://apps.producteca.com/oauth"

module.exports = 
class AuthApi
  constructor: (@accessToken) ->
  
  companyId: () => @_me().get("id")
  
  _me: () => @_doRequest("get", "/users/me", { access_token: @accessToken })
  
  
  _doRequest: (verb, path, qs = {}) => 
    options = {
      url: OAUTH_API_URL + path,
      qs,
      json: true
    }
    request[verb](options).promise()
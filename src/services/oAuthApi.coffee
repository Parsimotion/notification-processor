request = require("request-promise");

OAUTH_API_URL = process.env.OAUTH_API_URL or "https://apps.producteca.com/oauth" #TODO: Revisar que esta variable este seteada en todos lados con la interna, seguramente no

module.exports = 
class AuthApi
  constructor: (@accessToken) ->
  
  companyId: () => @_me().get("id") #TODO: Esto esta mal? deberia ser company.id
  
  _me: () => @_doRequest("get", "/users/me", { access_token: @accessToken, fromNotificationProcessor: true }) #TODO: Agregar cache aca!
  
  
  _doRequest: (verb, path, qs = {}) => 
    options = {
      url: OAUTH_API_URL + path,
      qs,
      json: true
    }
    request[verb](options).promise()
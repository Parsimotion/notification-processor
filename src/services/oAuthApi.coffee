request = require("request-promise");
Promise = require("bluebird")
NodeCache = require("node-cache")
translatedCache = new NodeCache { stdTTL: 0, checkperiod: 0 }
OAUTH_API_URL = process.env.OAUTH_API_URL or "https://apps.producteca.com/oauth" #TODO: Revisar que esta variable este seteada en todos lados con la interna, seguramente no

module.exports = 
class AuthApi
  constructor: (@accessToken) ->
  
  companyId: () => 
    cachedValue = translatedCache.get(@accessToken)
    return Promise.resolve(cachedValue.id) if cachedValue
    @_me().get("id") #TODO: Esto esta mal? deberia ser company.id
    .tap (id) => translatedCache.set(@accessToken, { id })
  
  _me: () => @_doRequest("get", "/users/me", { access_token: @accessToken, fromNotificationProcessor: true }) 
  
  
  _doRequest: (verb, path, qs = {}) => 
    options = {
      url: OAUTH_API_URL + path,
      qs,
      json: true
    }
    request[verb](options).promise()
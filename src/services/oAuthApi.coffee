request = require("request-promise");
Promise = require("bluebird")
NodeCache = require("node-cache")
translatedCache = new NodeCache { stdTTL: 0, checkperiod: 0 }
OAUTH_API_URL = process.env.OAUTH_API_URL or "https://apps.producteca.com/oauth" #TODO: Revisar que esta variable este seteada en todos lados con la interna, seguramente no

module.exports = 
class OAuthApi
  constructor: (@accessToken) ->
  
  scopes: () => 
    cachedValue = translatedCache.get(@accessToken)
    return Promise.resolve(cachedValue) if cachedValue
    @_scopes() #TODO: Esto esta mal? deberia ser company.id
    .tap ({ id, companyId, appId }) => translatedCache.set(@accessToken, { id, companyId, appId })
  
  _scopes: () => @_doRequest("get", "/scopes", { access_token: @accessToken, fromNotificationProcessor: true })
  
  
  _doRequest: (verb, path, qs = {}) => 
    options = {
      url: OAUTH_API_URL + path,
      qs,
      json: true
    }
    request[verb](options).promise()
_ = require("lodash");
OAuthApi = require("../services/oAuthApi");
Promise = require("bluebird")

_companyId = (method, token) =>
  console.log("TOKEN", token)
  if (method != "Basic")
    return new OAuthApi(token).companyId()
  decoded = Buffer.from(token, "base64").toString();
  _.split(decoded, ":")[0]

_resource = ({ Resource }) => _.reject(Resource, isNaN).join("")

module.exports =
  user: ({ message: { HeadersForRequest } }) => 
    auth = _.find(HeadersForRequest, { Key: "Authorization" })
    [method, token] = _.get(auth, "Value", "").split(" ")
    
    _companyId(method, token)
    .tap (it) => console.log("USEER", it)
  ,
  resource: ({ message }, resourceGetter) => 
    if _.isFunction(resourceGetter) then resourceGetter(message) else _resource(message)
  

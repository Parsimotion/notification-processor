_ = require("lodash");
OAuthApi = require("../services/oAuthApi");
Promise = require("bluebird")

_companyId = (method, token) =>
  console.log("TOKEN", token)
  if (method != "Basic")
    return new OAuthApi(token).companyId()
  decoded = Buffer.from(token, "base64").toString();
  Promise.resolve(_.split(decoded, ":")[0])

module.exports =
  user: ({ message: { HeadersForRequest } }) => 
    auth = _.find(HeadersForRequest, { Key: "Authorization" })
    [method, token] = _.get(auth, "Value", "").split(" ")
    
    _companyId(method, token)
    .tap (it) => console.log("USEER", it)
  ,
  resource: ({ message: { Body } }) => 
    parsedBody
    try 
      parsedBody = JSON.parse(Body)
    catch e 
      parsedBody = null
    console.log("resource", parsedBody && parsedBody.channelProductId)
    "test" #parsedBody && parsedBody.channelProductId
  

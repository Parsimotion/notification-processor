_ = require("lodash");
OAuthApi = require("../services/oAuthApi");

_companyId = (method, token) =>
  if (method != "Basic")
    return new OAuthApi token.companyId();
  decoded = Buffer.from(token, "base64").toString();
  _.split(decoded, ":")[0];

module.exports =
  user: ({ message: { HeadersForRequest } }) => 
    auth = _.find(HeadersForRequest, { Key: "Authorization" })
    [method, token] = _.get(auth, "Value", "").split(" ");
    _companyId(method, token);
  ,
  resource: ({ message: { Body } }) => 
    parsedBody
    try 
      parsedBody = JSON.parse(Body)
    catch e 
      parsedBody = null
    parsedBody && parsedBody.channelProductId;
  

_ = require "lodash"
request = require("request-promise")
retry = require("bluebird-retry")

class NotificationsApi
  constructor: ({ @notificationApiUrl, @token, @jobId }) ->

  success: ({ statusCode }) => retry(( =>
     @_makeRequest { statusCode, success: yes }
  ), { max_tries: 3 }).catchReturn()

  fail: ({ statusCode, error, request }) => retry(( =>
    @_makeRequest { statusCode, success: no, message: _.get(error, "message"), request }
  ), { max_tries: 3 }).catchReturn()

  _makeRequest: (body) =>
    request {
      url: "#{ @notificationApiUrl }/jobs/#{ @jobId }/operations"
      method: "POST"
      headers: { authorization: @token }
      json: body
    }

module.exports = NotificationsApi

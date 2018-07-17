NOTIFICATIONS_URL = process.env.NOTIFICATIONS_API_URL

_ = require "lodash"
request = require("request-promise")
retry = require("bluebird-retry")

class NotificationsApi
  constructor: (@token) ->

  success: ({ message: { jobId }, statusCode }) => retry(( =>
     @_makeRequest jobId, { statusCode, success: yes }
  ), { max_tries: 3 }).catchReturn()

  fail: ({ message: { jobId }, statusCode, error, request }) => retry(( =>
    @_makeRequest jobId, { statusCode, success: no, message: _.get(error, "message"), request }
  ), { max_tries: 3 }).catchReturn()

  _makeRequest: (jobId, body) =>
    request {
      url: "#{NOTIFICATIONS_URL}/jobs/#{jobId}/operations"
      method: "POST"
      headers: { authorization: @token }
      json: body
    }

module.exports = NotificationsApi

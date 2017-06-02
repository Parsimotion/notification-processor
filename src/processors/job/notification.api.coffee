NOTIFICATIONS_URL = process.env.NOTIFICATIONS_API_URL

_ = require "lodash"
requestPromise = require("request-promise")
retry = require("bluebird-retry")

class NotificationsApi
  constructor: (@token) ->

  success: ({ message: { JobId }, statusCode }) => retry(( =>
    requestPromise @_makeRequest JobId, { statusCode, success: yes }
  ), { max_tries: 3 }).catchReturn()

  fail: ({ message, statusCode, error, request }) => retry(( =>
    requestPromise @_makeRequest message.JobId, { statusCode, success: no, message: error.message, request }
  ), { max_tries: 3 }).catchReturn()

  _makeRequest: (jobId, body) =>
    url: "#{NOTIFICATIONS_URL}/jobs/#{jobId}/operations"
    method: "POST"
    headers: { authorization: @token }
    json: body

module.exports = NotificationsApi

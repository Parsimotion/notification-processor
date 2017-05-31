NOTIFICATIONS_URL = process.env.NOTIFICATIONS_API_URL

request = require("request-promise")
retry = require("bluebird-retry")

class NotificationsApi
  constructor: (@token) ->
  success: (jobId, statusCode) => retry(( => request(@_makeRequest(jobId, { statusCode, success: yes }))), { max_tries: 3 })
  fail: (jobId, statusCode, { message }) => retry(( => request(@_makeRequest(jobId, { statusCode, success: no, message }))), { max_tries: 3 })

  _makeRequest: (jobId, body) =>
    url: "#{NOTIFICATIONS_URL}/jobs/#{jobId}/operations"
    method: "POST"
    headers: { authorization: @token }
    json: body

module.exports = NotificationsApi

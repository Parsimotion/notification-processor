NOTIFICATIONS_URL = process.env.NOTIFICATIONS_API_URL

request = require("request-promise")

class NotificationsApi
  constructor: (@token) ->
  success: (jobId, statusCode) => request @_makeRequest jobId, { statusCode, success: yes }
  fail: (jobId, statusCode, { message }) => request @_makeRequest jobId, { statusCode, success: no, message }

  _makeRequest: (jobId, body) =>
    url: "#{NOTIFICATIONS_URL}/jobs/#{jobId}/operations"
    method: "POST"
    headers: { authorization: @token }
    json: body

module.exports = NotificationsApi

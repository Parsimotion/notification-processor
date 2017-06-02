NOTIFICATIONS_URL = process.env.NOTIFICATIONS_API_URL

request = require("request-promise")
retry = require("bluebird-retry")

class NotificationsApi
  constructor: (@token) ->

  success: ({ message: { JobId }, statusCode }) => retry(( =>
    request(@_makeRequest(JobId, { statusCode, success: yes }))
  ), { max_tries: 3 })

  fail: ({ message: { JobId }, statusCode, error: { message: errorMessage } }) => retry(( =>
    request(@_makeRequest(JobId, { statusCode, success: no, message: errorMessage }))
  ), { max_tries: 3 })

  _makeRequest: (jobId, body) =>
    url: "#{NOTIFICATIONS_URL}/jobs/#{jobId}/operations"
    method: "POST"
    headers: { authorization: @token }
    json: body

module.exports = NotificationsApi

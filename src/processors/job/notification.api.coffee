_ = require "lodash"
request = require("request-promise")
retry = require("bluebird-retry")
Promise = require("bluebird")
NodeCache = require("node-cache");
NOTIFICATIONS_API_JOB_CACHE_TTL = parseInt(process.env.NOTIFICATIONS_API_JOB_CACHE_TTL) or 5
jobCache = new NodeCache({ stdTTL: NOTIFICATIONS_API_JOB_CACHE_TTL });

class NotificationsApi
  constructor: ({ @notificationApiUrl, @token, @jobId }) ->

  success: ({ statusCode }) => retry(( =>
     @_makeRequest { statusCode, success: yes }
  ), { max_tries: 3 }).catchReturn()

  fail: ({ statusCode, error, request }) => retry(( =>
    message = _.get error, "message"
    @_makeRequest { statusCode, success: no, message, request }
  ), { max_tries: 3 }).catchReturn()
  
  jobIsStopped: () => 
    @_fetchJob()
    .then (job) => job.stopped

  _fetchJob: () => 
    cachedJob = jobCache.get @jobId
    return Promise.resolve cachedJob if cachedJob?
    @_doFetchJob()
    .tap (job) => jobCache.set @jobId, job

  _doFetchJob: () => 
    retry => request {
      url: "#{ @notificationApiUrl }/jobs/#{ @jobId }"
      method: "GET"
      headers: { authorization: @token }
    }

  _makeRequest: (body) =>
    request {
      url: "#{ @notificationApiUrl }/jobs/#{ @jobId }/operations"
      method: "POST"
      headers: { authorization: @token }
      json: body
    }

module.exports = NotificationsApi

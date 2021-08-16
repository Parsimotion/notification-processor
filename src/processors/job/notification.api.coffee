_ = require "lodash"
request = require("request-promise")
retry = require("bluebird-retry")
Promise = require("bluebird")
NodeCache = require("node-cache");
NOTIFICATIONS_API_JOBS_CACHE_TTL = parseInt(process.env.NOTIFICATIONS_API_JOBS_CACHE_TTL) or 5
NOTIFICATIONS_API_STOPPED_JOB_CACHE_TTL = parseInt(process.env.NOTIFICATIONS_API_STOPPED_JOB_CACHE_TTL) or 2
HOUR = 60 * 60

#Para minimizar las requests a notifications-api, cachea unos segundos el estado del job
jobsCache = new NodeCache({ stdTTL: NOTIFICATIONS_API_JOBS_CACHE_TTL })
#A nivel dominio, podria ser cache sin TTL porque un job stoppeado queda asi para siempre. Pero se pone TTL de 2h para que luego libere la memoria
stoppedJobsCache = new NodeCache({ stdTTL: NOTIFICATIONS_API_STOPPED_JOB_CACHE_TTL * HOUR }); 

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
    cachedStoppedJob = stoppedJobsCache.get @jobId
    return Promise.resolve cachedStoppedJob if cachedStoppedJob?
    @_jobIsStopped()
    .tap (jobIsStopped) => stoppedJobsCache.set(@jobId, job) if jobIsStopped
  
  _jobIsStopped: () => 
    @_fetchJob()
    .then (job) => job.stopped

  _fetchJob: () => 
    cachedJob = jobsCache.get @jobId
    return Promise.resolve cachedJob if cachedJob?
    @_doFetchJob()
    .tap (job) => jobsCache.set @jobId, job

  _doFetchJob: () => 
    __fetchJob = () => request({
      url: "#{ @notificationApiUrl }/jobs/#{ @jobId }"
      method: "GET"
      headers: { authorization: @token }
    }).promise()

    retry __fetchJob, throw_original: true

  _makeRequest: (body) =>
    request {
      url: "#{ @notificationApiUrl }/jobs/#{ @jobId }/operations"
      method: "POST"
      headers: { authorization: @token }
      json: body
    }

module.exports = NotificationsApi

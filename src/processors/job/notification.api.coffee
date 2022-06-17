_ = require "lodash"
requestPromise = require("request-promise")
retry = require("bluebird-retry")
Promise = require("bluebird")
NodeCache = require("node-cache");
NOTIFICATIONS_API_JOBS_CACHE_TTL = parseInt(process.env.NOTIFICATIONS_API_JOBS_CACHE_TTL) or 5
NOTIFICATIONS_API_STOPPED_JOB_CACHE_TTL = parseInt(process.env.NOTIFICATIONS_API_STOPPED_JOB_CACHE_TTL) or 2
DEFAULT_NOTIFICATIONS_API_ASYNC_URL = process.env.DEFAULT_NOTIFICATIONS_API_ASYNC_URL || "https://apps.producteca.com/aws/notifications-api-async"
HOUR = 60 * 60

#Para minimizar las requests a notifications-api, cachea unos segundos el estado del job
jobsCache = new NodeCache({ stdTTL: NOTIFICATIONS_API_JOBS_CACHE_TTL })
#A nivel dominio, podria ser cache sin TTL porque un job stoppeado queda asi para siempre. Pero se pone TTL de 2h para que luego libere la memoria
stoppedJobsCache = new NodeCache({ stdTTL: NOTIFICATIONS_API_STOPPED_JOB_CACHE_TTL * HOUR }); 
class NotificationsApi
  constructor: ({ @notificationApiUrl, @token, @jobId, @notificationApiAsyncUrl = DEFAULT_NOTIFICATIONS_API_ASYNC_URL }) ->

  success: (response, options) => 
    { statusCode } = response;
    __makeRequest = () => @_makeRequest { statusCode, success: yes }, options
    __retryRequest = () => @success(response, { async: true })
    
    @_retryViaAsyncOrIgnore(__makeRequest, __retryRequest, options)

  fail: (response, options) => 
    { statusCode, error, request } = response
    message = _.get error, "message"
    __makeRequest = () => @_makeRequest { statusCode, success: no, message, request }, options
    __retryRequest = () => @fail(response, { async: true })
    
    @_retryViaAsyncOrIgnore(__makeRequest, __retryRequest, options)

  jobIsStopped: () => 
    cachedStoppedJob = stoppedJobsCache.get @jobId
    return Promise.resolve cachedStoppedJob if @_shouldUseCachedValue(cachedStoppedJob)
    @_jobIsStopped()
    .tap (jobIsStopped) => stoppedJobsCache.set(@jobId, jobIsStopped) if jobIsStopped
  
  _jobIsStopped: () => 
    @_fetchJob()
    .then (job) => job.stopped

  _fetchJob: () => 
    cachedJob = jobsCache.get @jobId
    return Promise.resolve cachedJob if @_shouldUseCachedValue(cachedJob)
    @_doFetchJob()
    .tap (job) => jobsCache.set @jobId, job

  _doFetchJob: () => 
    __fetchJob = () => requestPromise({
      url: "#{ @notificationApiUrl }/jobs/#{ @jobId }"
      method: "GET"
      headers: { authorization: @token }
      json: true
    }).promise()

    retry __fetchJob, throw_original: true

  _retryViaAsyncOrIgnore: (makeRequest, retryRequest, options = {}) =>    
    retry(makeRequest, { throw_original: true, max_tries: 3 })
    .catch (e) =>
      throw e if options.async
      console.log("Error sending status to notifications-api. Retrying via notifications-api-async")
      asyncOptions = _.assign({}, options, { async: true })
      retryRequest()
    .catchReturn()

  _makeRequest: (body, { async } = {}) =>
    url = if async then @notificationApiAsyncUrl else @notificationApiUrl
    requestPromise {
      url: "#{ url }/jobs/#{ @jobId }/operations"
      method: "POST"
      headers: { authorization: @token }
      json: body
    }
  
  _shouldUseCachedValue: (value) =>
    process.env.NODE_ENV isnt "test" and value?

module.exports = NotificationsApi

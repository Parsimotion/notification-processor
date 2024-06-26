_ = require("lodash")
JobProcessor = require "./job.processor"
RequestAsyncProcessor = require "../request.async.processor"

module.exports = ({ apiUrl, notificationApiUrl, maxRetries, nonRetryable = [400], silentErrors = [] }) ->
  jobProcesor = new JobProcessor {
    processor: RequestAsyncProcessor { apiUrl, fullResponse: true, silentErrors }
    maxRetries
    nonRetryable
    silentErrors
    notificationApiUrl
  }

  (it, context, executionId) -> jobProcesor.process it, context, executionId
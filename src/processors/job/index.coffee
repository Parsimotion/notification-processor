_ = require("lodash")
JobProcessor = require "./job.processor"
RequestProcessor = require "../request.async.processor"

module.exports = ({ apiUrl, notificationApiUrl, maxRetries, nonRetryable = [400] }) ->
  jobProcesor = new JobProcessor {
    processor: RequestProcessor { apiUrl, fullResponse: true }
    maxRetries
    nonRetryable
    notificationApiUrl
  }

  (it) -> jobProcesor.process it
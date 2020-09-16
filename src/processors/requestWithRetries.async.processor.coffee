_ = require "lodash"
RequestAsyncProcessor = require "./request.async.processor"
MaxRetriesProcessor = require "./deadletter.processor"

module.exports = (args) ->
  { maxRetries = 5 } = args
  processor = RequestAsyncProcessor args
  withMaxRetries = new MaxRetriesProcessor({ processor, maxRetries })
  withMaxRetries.process.bind withMaxRetries
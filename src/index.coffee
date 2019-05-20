module.exports =
  Builder: require "./processor.builder"
  Observers:
    LoggerObserver: require "./observers/logger.observer"
    DelayObserver: require "./observers/delay.observer"
    DeadLetterSucceeded: require "./observers/deadLetterSucceeded.observer"
  Processors:
    RequestProcessor: require "./processors/request.processor"
    RequestAsyncProcessor: require "./processors/request.async.processor"
    JobProcessor: require "./processors/job"
    DeadletterProcessor: require "./processors/deadletter"
    MaxRetriesProcessor: require "./processors/maxRetries.processor"
  Sources: require "./sources"
  Senders: require "./senders"

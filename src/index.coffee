module.exports =
  Builder: require "./processor.builder"
  Observers:
    LoggerObserver: require "./observers/logger.observer"
    DelayObserver: require "./observers/delay.observer"
    DeadLetterSucceeded: require "./observers/deadLetterSucceeded.observer"
  Processors:
    RequestProcessor: require "./processors/request.processor"
    JobProcessor: require "./processors/job"
    DeadletterProcessor: require "./processors/deadletter"
  Sources: require "./sources"

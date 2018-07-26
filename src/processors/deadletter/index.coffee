DeadletterProcessor = require("./deadletter.processor")

module.exports =
  ({ connection, table = "poison", name, sender, maxDequeueCount = 1 }, processor) ->
    processor = new DeadletterProcessor {
      processor
      sender
      maxRetries: maxDequeueCount
      storage: {
        table
        connection
        name
      }
    }

    (it) -> processor.process it
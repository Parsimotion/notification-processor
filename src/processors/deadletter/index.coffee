module.exports =
  ({ connection, table = "poison", name, rowKeyGenerator, maxDequeueCount = 1 }, processor) ->
    processor = new DeadletterProcessor
      processor
      maxRetries: maxDequeueCount
      storage:
        table
        connection
        name
        rowKeyGenerator

    (it) -> jobProcesor.process it
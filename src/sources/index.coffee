module.exports =
  AwsSQSSource: require "./aws.sqs.source"
  ServiceBusSource: require "./service.bus.source"
  QueueSource: require "./queue.source"
  TableSource: require "./table.source"
  UnknownSource: require "./unknown.source"

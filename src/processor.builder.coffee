_ = require "lodash"
Processor = require "./processor"
logger = require "./observers/logger.observer"
{ UnknownSource, ServiceBusSource, QueueSource, AwsSQSSource, AwsSNSSource } = require "./sources"
{ MeliSender, ProductecaSender } = require "./senders"

class ProcessorBuilder

  constructor: ->
    @source = UnknownSource
    @listeners = []

  @create: -> new @

  withSource: (@source) -> @

  withSender: (@sender) -> @

  withTimeout: (@timeout) -> @

  withApm: (@apm) -> @

  fromServiceBus: -> @withSource ServiceBusSource

  fromAwsSNS: -> @withSource AwsSNSSource

  fromAwsSQS: -> @withSource AwsSQSSource

  fromQueue: -> @withSource QueueSource

  fromMeli: -> @withSender MeliSender

  fromProducteca: -> @withSender ProductecaSender

  withFunction: (@command) -> @

  withLogging: ->
    @withListeners logger

  withListeners: (args...) ->
    @listeners = _.concat @listeners, args
    @

  build: ->
    processor = new Processor { @source, runner: @command, @timeout, @apm }
    _.forEach @listeners, (listener) ->
      listener.listenTo processor

    processor

module.exports = ProcessorBuilder

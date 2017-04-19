_ = require "lodash"
Processor = require "./processor"
logger = require "./observers/logger.observer"
{ UnknownSource, ServiceBusSource, QueueSource } = require "./sources"

class ProcessorBuilder

  constructor: ->
    @source = UnknownSource
    @listeners = []

  @create: -> new @

  withSource: (@source) -> @

  withDelayObserver: (opts) ->
    @withListeners @source.delayObserver opts

  withDeadLetterSucceeded: (opts) ->
    @withListeners @source.deadLetterSucceeded opts

  withDidLastRetry: (opts) ->
    @withListeners @source.didLastRetry opts

  fromServiceBus: -> @withSource ServiceBusSource

  fromQueue: -> @withSource QueueSource

  withFunction: (@command) -> @

  withLogging: ->
    @withListeners logger

  withListeners: (args...) ->
    @listeners = _.concat @listeners, args
    @

  build: ->
    processor = new Processor { @source, runner: @command }
    _.forEach @listeners, (listener) ->
      listener.listenTo processor

    processor

module.exports = ProcessorBuilder

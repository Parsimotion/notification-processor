_ = require "lodash"
Processor = require "./processor"
logger = require "./observers/logger.observer"
{ UnknownSource, ServiceBusSource, QueueSource } = require "./sources"
{ MeliSender, ProductecaSender } = require "./senders"

class ProcessorBuilder

  constructor: ->
    console.log "FFF"
    @source = UnknownSource
    @listeners = []

  @create: -> new @

  withSource: (@source) -> @

  withSender: (@sender) -> @

  withTimeout: (@timeout) -> @

  withApm: (@apm) -> @

  withDelayObserver: (opts) ->
    @withListeners @source.delayObserver opts

  withDeadLetterSucceeded: (opts) ->
    throw new Error "Sender is required" unless @sender?
    @withListeners @source.deadLetterSucceeded _.defaults(opts, { @sender })

  withDidLastRetry: (opts) ->
    throw new Error "Sender is required" unless @sender?
    @withListeners @source.didLastRetry _.defaults(opts, { @sender })

  fromServiceBus: -> @withSource ServiceBusSource

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

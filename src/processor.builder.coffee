_ = require "lodash"
Processor = require "./processor"
logger = require "./observers/logger.observer"
ServiceBusAdapter = require "./service.bus.adapter"

module.exports =
  class ProcessorBuilder

    constructor: ->
      @listeners = []
      @adapter = _.identity

    @create: -> new @

    fromServiceBus: ->
      @adapter = ServiceBusAdapter
      @

    withFunction: (@command) -> @

    withLogging: ->
      @withListeners logger

    withListeners: (args...) ->
      @listeners = _.concat @listeners, args
      @

    ignoreUsers: () ->
      @

    build: ->
      processor = new Processor @adapter, @command
      _.forEach @listeners, (listener) ->
        listener.listenTo processor

      processor

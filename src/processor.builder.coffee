_ = require "lodash"
Processor = require "./processor"
logger = require "./observers/logger.observer"
ServiceBusAdapter = require "./service.bus.adapter"
IgnoreUsers = require "./ignore.user.filter"
QueueAdapter = require "./queue.adapter"

module.exports =
  class ProcessorBuilder

    constructor: ->
      @listeners = []
      @adapter = _.identity
      @filters = []

    @create: -> new @

    fromServiceBus: ->
      @adapter = ServiceBusAdapter
      @

    fromQueue: ->
      @adapter = QueueAdapter
      @

    withFunction: (@command) -> @

    withLogging: ->
      @withListeners logger

    withListeners: (args...) ->
      @listeners = _.concat @listeners, args
      @

    ignoreUsers: () ->
      @filters = _.concat @filters, IgnoreUsers
      @

    build: ->
      processor = new Processor @filters, @adapter, @command
      _.forEach @listeners, (listener) ->
        listener.listenTo processor

      processor

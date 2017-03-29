_ = require "lodash"
Processor = require "./processor"
logger = require "./logger.subscriber"

module.exports =
  class ProcessorBuilder

    constructor: ->
      @listeners = []

    @create: -> new @

    withFunction: (@command) -> @

    withLogging: ->
      @listeners.push logger
      @

    build: ->
      processor = new Processor @command
      _.forEach @listeners, (listener) ->
        listener.listenTo processor

      processor

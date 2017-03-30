_ = require "lodash"
Processor = require "./processor"
logger = require "./observers/logger.observer"

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

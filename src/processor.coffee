_ = require "lodash"
NonRetryable = require "./exceptions/non.retryable"
EventEmitter = require "events"
Promise = require "bluebird"
uuid = require "uuid/v4"

ENABLE_EVENTS = process.env.ENABLE_EVENTS isnt "false"

module.exports =
  class Processor extends EventEmitter

    constructor: ({ @source, @runner, @timeout }) -> super()

    process: (raw, context) =>
      id = uuid()
      notification = @source.newNotification { context, id, message: raw }

      @_emitEvent "started", { context, id, notification }
      $promise = Promise.method(@runner) notification, context
      $promise = $promise.timeout(@timeout, "processor timeout") if @timeout?

      $promise
      .tap => @_emitEvent "successful", { context, id, notification }
      .catch NonRetryable, (error) => @_emitEvent "unsuccessful_non_retryable", { context, id, notification, error }
      .tapCatch (error) => @_emitEvent "unsuccessful", { context, id, notification, error }
      .finally => @_emitEvent "finished", { context, id, notification }
      .asCallback context.done

      return

    _emitEvent: (eventName, value) =>
      @emit eventName, value if ENABLE_EVENTS

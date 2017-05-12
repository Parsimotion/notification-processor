_ = require "lodash"
EventEmitter = require "events"
Promise = require "bluebird"

ENABLE_EVENTS = process.env.ENABLE_EVENTS isnt "false"

module.exports =
  class Processor extends EventEmitter

    constructor: ({ @source, @runner }) ->

    process: (context, raw) =>
      notification = @source.newNotification { context, message: raw }

      @_emitEvent "started", { context, notification }
      if @source.shouldBeIgnored { notification }
        @_emitEvent "ignored", { context, notification }
        context.done()
        return

      Promise.method(@runner) notification, context
      .tap => @_emitEvent "successful", { context, notification }
      .thenReturn()
      .tapCatch (err) => @_emitEvent "unsuccessful", { context, notification, err }
      .finally => @_emitEvent "finished", { context, notification }
      .asCallback context.done

      return

    _emitEvent: (eventName, value) =>
      @emit eventName, value if ENABLE_EVENTS

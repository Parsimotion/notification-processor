_ = require "lodash"
EventEmitter = require "events"
Promise = require "bluebird"
uuid = require "uuid/v4"

ENABLE_EVENTS = process.env.ENABLE_EVENTS isnt "false"

module.exports =
  class Processor extends EventEmitter

    constructor: ({ @source, @runner }) -> super()

    process: (context, raw) =>
      id = uuid()
      notification = @source.newNotification { context, id, message: raw }

      @_emitEvent "started", { context, id, notification }
      Promise.method(@runner) notification, context
      .tap => @_emitEvent "successful", { context, id, notification }
      .tapCatch (error) => @_emitEvent "unsuccessful", { context, id, notification, error}
      .finally => @_emitEvent "finished", { context, id, notification }
      .asCallback context.done

      return

    _emitEvent: (eventName, value) =>
      @emit eventName, value if ENABLE_EVENTS

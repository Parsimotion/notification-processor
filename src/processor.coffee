_ = require "lodash"
EventEmitter = require "events"
Promise = require "bluebird"

module.exports =
  class Processor extends EventEmitter

    constructor: ({ @source, @runner }) ->

    process: (context, raw) =>
      notification = @source.newNotification { context, message: raw }

      @emit "started", { context, notification }
      if @source.shouldBeIgnore { notification }
        @emit "ignored", { context, notification }
        context.done()
        return

      Promise.method(@runner) notification
      .tap => @emit "successful", { context, notification }
      .thenReturn()
      .tapCatch (err) => @emit "unsuccessful", { context, notification, err }
      .finally => @emit "finished", { context, notification }
      .asCallback context.done

      return

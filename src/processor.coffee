_ = require "lodash"
EventEmitter = require "events"
Promise = require "bluebird"

module.exports =
  class Processor extends EventEmitter

    constructor: (@runner) ->
      super()

    process: (context, message) =>
      @emit "started", { context, message }
      Promise.method(@runner) message
      .tap => @emit "successful", { context, message }
      .thenReturn()
      .tapCatch (err) => @emit "unsuccessful", { context, message, err }
      .finally => @emit "finished", { context, message }
      .asCallback context.done

      return

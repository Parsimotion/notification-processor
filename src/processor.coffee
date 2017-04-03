_ = require "lodash"
EventEmitter = require "events"
Promise = require "bluebird"

module.exports =
  class Processor extends EventEmitter

    constructor: (@adapter, @runner) ->

    process: (context, raw) =>
      { meta, message } = @adapter { context, message: raw }

      @emit "started", { context, message, meta }
      Promise.method(@runner) { message, meta }
      .tap => @emit "successful", { context, message, meta }
      .thenReturn()
      .tapCatch (err) => @emit "unsuccessful", { context, message, meta, err }
      .finally => @emit "finished", { context, message, meta }
      .asCallback context.done

      return

_ = require "lodash"
errorToJson = require "error-to-json"
Promise = require "bluebird"

module.exports =
  class Processor

    constructor: (@runner) ->

    process: ({ done, log }, message) ->
      log "An new message has been received", message

      Promise.method(@runner) message
      .tap -> log "Process successful"
      .thenReturn()
      .tapCatch (err) -> log "Process unsuccessful", errorToJson(err)
      .asCallback done

      return

errorToJson = require "error-to-json"

module.exports =
  listenTo: (observable) ->
    observable.on "started", ({ context: { log }, message })->
      log "An new message has been received", message

    observable.on "successful", ({ context: { log } }) ->
      log "Process successful"

    observable.on "unsuccessful", ({ context: { log }, err }) ->
      log "Process unsuccessful", errorToJson(err)

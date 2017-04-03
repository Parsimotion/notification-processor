errorToJson = require "error-to-json"

module.exports =
  listenTo: (observable) ->
    observable.on "started", ({ context: { log }, message })->
      log "A new message has been received", message

    observable.on "successful", ({ context: { log } }) ->
      log "Process successful"

    observable.on "unsuccessful", ({ context: { log }, err }) ->
      log "Process unsuccessful", errorToJson(err)

    observable.on "finished", ({ context: { log } }) ->
      log "Process finished"

    observable.on "ignored", ({ context: { log }, message }) ->
      log "Message ignored", message

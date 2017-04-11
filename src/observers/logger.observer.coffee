errorToJson = require "error-to-json"

module.exports =
  listenTo: (observable) ->
    observable.on "started", ({ context: { log }, notification })->
      log "A new message has been received", notification

    observable.on "successful", ({ context: { log } }) ->
      log "Process successful"

    observable.on "unsuccessful", ({ context: { log }, err }) ->
      log "Process unsuccessful", errorToJson(err)

    observable.on "finished", ({ context: { log } }) ->
      log "Process finished"

    observable.on "ignored", ({ context: { log }, notification }) ->
      log "Message ignored", notification

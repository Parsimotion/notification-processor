errorToJson = require "error-to-json"

module.exports =
  listenTo: (observable) ->
    observable.on "started", ({ context: { log }, notification }) ->
      log.info "A new message has been received", { notification }

    observable.on "successful", ({ context: { log }, notification }) ->
      log.info "Process successful", { notification }

    observable.on "unsuccessful", ({ context: { log }, notification, error }) ->
      log.error "Process unsuccessful", { notification, error: errorToJson(error) }

    observable.on "finished", ({ context: { log }, notification }) ->
      log.info "Process finished", { notification }

    observable.on "ignored", ({ context: { log }, notification }) ->
      log.verbose "Message ignored", { notification }

errorToJson = require "error-to-json"

module.exports =
  listenTo: (observable) ->
    observable.on "started", ({ context: { log }, notification, id }) ->
      log.info "A new message has been received", { id, notification: JSON.stringify(notification) }

    observable.on "successful", ({ context: { log }, id }) ->
      log.info "Process successful", { id }

    observable.on "unsuccessful", ({ context: { log }, id, error }) ->
      log.error "Process unsuccessful", { id, notification: JSON.stringify(notification), error: JSON.stringify(errorToJson(error)) }

    observable.on "ignored", ({ context: { log }, id }) ->
      log.verbose "Message ignored", { id }

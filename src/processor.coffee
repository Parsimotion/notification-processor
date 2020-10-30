_ = require "lodash"
NonRetryable = require "./exceptions/non.retryable"
EventEmitter = require "events"
Promise = require "bluebird"
uuid = require "uuid/v4"
newrelic = _.once -> require("newrelic")

ENABLE_EVENTS = process.env.ENABLE_EVENTS isnt "false"

module.exports =
  class Processor extends EventEmitter

    constructor: ({ @source, @runner, @timeout, @apm }) -> super()

    process: (context, raw) =>
      id = uuid()
      notification = @source.newNotification { context, id, message: raw }

      @_emitEvent "started", { context, id, notification }
      $promise = Promise.method(@runner) notification, context
      $promise = $promise.timeout(@timeout, "processor timeout") if @timeout?

      promise = () -> $promise
      .tap => @_emitEvent "successful", { context, id, notification }
      .catch (error) =>
        throw error unless error instanceof NonRetryable
        @_emitEvent "unsuccessful_non_retryable", { context, id, notification, error }
      .tapCatch (error) => @_emitEvent "unsuccessful", { context, id, notification, error }
      .finally => @_emitEvent "finished", { context, id, notification }
      .asCallback context.done

      return promise() unless @apm.active

      transactionName = "test-transact" #_.compact([@config.topic, @_subscriptionName(), folderScript()]).join "-"
      newrelic().startBackgroundTransaction transactionName, "test", () ->
        promise()
        .tapCatch (err) -> newrelic().noticeError err

      

    _emitEvent: (eventName, value) =>
      @emit eventName, value if ENABLE_EVENTS

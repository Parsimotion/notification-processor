module.exports =
class NonRetryable
  constructor: (message) ->
    @name = @constructor.name
    @message = message
    @stack = (new Error).stack

  @:: = new Error
  @::constructor = @
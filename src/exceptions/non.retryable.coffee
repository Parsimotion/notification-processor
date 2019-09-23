module.exports =
  class NonRetryable
    constructor: (message, @cause) ->
      @name = @constructor.name
      @message = message
      @stack = (new Error).stack

    @:: = new Error
    @::constructor = @
module.exports =
  class NonRetryable
    constructor: ({ message, code }, @cause) ->
      @name = @constructor.name
      @message = message
      @statusCode = @cause?.statusCode or @cause?.detail?.response?.statusCode
      @code = @cause?.code or code
      @stack = (new Error).stack

    @:: = new Error
    @::constructor = @
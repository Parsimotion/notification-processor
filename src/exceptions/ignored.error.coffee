module.exports =
  class IgnoredError
    constructor: (message, @cause) ->
      @name = @constructor.name
      @message = message
      @stack = (new Error).stack

    @:: = new Error
    @::constructor = @
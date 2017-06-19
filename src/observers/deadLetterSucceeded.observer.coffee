RedisObserver = require "./redis.observer"

module.exports =
  class DeadLetterSucceededObserver extends RedisObserver

    constructor: ({ redis, @app, @path, @sender }) ->
      super { redis }

    listenTo: (observable) =>
      observable.on "successful", @success

    success: ({ notification }) =>
      @publish notification, success: true

    _messagePath_: (notification) ->
      "#{@app}/#{@sender.user(notification)}/#{@path}/#{@sender.resource(notification)}"

    _channelPrefix_: (type) -> "health-message-#{type}"
    _buildValue_: JSON.stringify

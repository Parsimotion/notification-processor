RedisObserver = require "./redis.observer"

module.exports =
  class DidLastRetry extends RedisObserver

    constructor: ({ redis, @app, @path, @maxDeliveryCount = 5, @sender }) ->
      super { redis }

    listenTo: (observable) =>
      observable.on "unsuccessful", @error

    error: ({ notification, error }) =>
      if notification.meta.dequeueCount >= @maxDeliveryCount
        @publish notification, { success: false, value: { error } }
      else Promise.resolve()

    _messagePath_: (notification) =>
      "#{@app}/#{@sender.user(notification)}/#{@path}/#{@sender.resource(notification)}"

    _channelPrefix_: (type) => "health-message-#{type}"
    _buildValue_: JSON.stringify

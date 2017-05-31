RedisObserver = require "./redis.observer"

module.exports =
  class DidLastRetry extends RedisObserver

    constructor: ({ redis, @app, @path, @maxDeliveryCount = 5 }) ->
      super { redis }

    listenTo: (observable) =>
      observable.on "unsuccessful", @error

    error: ({ notification, error }) =>
      if notification.meta.dequeueCount >= @maxDeliveryCount
        @publish notification, { success: false, error }
      else Promise.resolve()

    _messagePath_: ({ message: { CompanyId, ResourceId } }) ->
      "#{@app}/#{CompanyId}/#{@path}/#{ResourceId}"

    _channelPrefix_: (type) -> "health-message-#{type}"
    _buildValue_: JSON.stringify
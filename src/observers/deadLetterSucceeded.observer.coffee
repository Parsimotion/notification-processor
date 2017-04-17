RedisObserver = require "./redis.observer"

module.exports =
  class DeadLetterSucceededObserver extends RedisObserver

    constructor: ({ redis, @app, @path }) ->
      super { redis }

    listenTo: (observable) =>
      observable.on "successful", @success

    success: ({ notification }) =>
      @publish notification, success: true

    _messagePath_: ({ message: { CompanyId, ResourceId } }) ->
      "#{@app}/#{CompanyId}/#{@path}/#{ResourceId}"

    _channelPrefix_: (type) -> "health-message-#{type}"
    _buildValue_: JSON.stringify

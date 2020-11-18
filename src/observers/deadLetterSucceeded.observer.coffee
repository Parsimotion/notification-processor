Promise = require "bluebird"
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
      Promise.props
        user: @sender.user notification
        resource: @sender.resource notification
      .then ({ user, resource }) => "#{@app}/#{user}/#{@path}/#{resource}"

    _channelPrefix_: (type) -> "health-message-#{type}"
    _buildValue_: JSON.stringify

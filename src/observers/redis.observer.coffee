Redis = require "../services/redis"
Promise = require "bluebird"

module.exports =
  class RedisObserver
    constructor: (redisConfig) ->
      @redis = Redis.createClient redisConfig.port, redisConfig.host, db: redisConfig.db
      @redis.auth redisConfig.auth if redisConfig.auth
      { @app, @topic, @subscription } = redisConfig

    publish: (message, value) =>
      @redis.publishAsync @_getChannel(message), @_buildValue_(value)

    _buildValue_: (value) ->
      JSON.stringify value

    _getChannel: (message) =>
        { CompanyId, ResourceId } = message
        "#{@_channelPrefix_()}/#{@app}/#{CompanyId}/#{@topic}/#{@subscription}/#{ResourceId}"

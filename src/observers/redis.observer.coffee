_ = require "lodash"
Redis = require "../services/redis"
Promise = require "bluebird"

module.exports =
  class RedisObserver
    constructor: ({ redis = {} }) ->
      _.defaults redis,
        host: process.env.REDIS_HOST
        port: process.env.REDIS_PORT
        db: process.env.REDIS_DB
        auth: process.env.REDIS_AUTH

      @redis = Redis.createClient redis.port, redis.host, db: redis.db
      @redis.auth redis.auth if redis.auth

    publish: (notification, value) =>
      @redis.publishAsync @_getChannel(notification), @_buildValue_(value)

    _getChannel: (notification) =>
      "#{@_channelPrefix_(notification.type)}/#{@_messagePath_ notification}"

    _messagePath_: => throw new Error "not supported `_messagePath_`"
    _buildValue_: => throw new Error "not supported `_buildValue_`"
    _channelPrefix_: (type) => throw new Error "not supported `_channelPrefix_`"

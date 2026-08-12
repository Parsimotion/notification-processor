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

      socketOptions = host: redis.host
      socketOptions.port = Number redis.port if redis.port

      clientOptions = socket: socketOptions
      clientOptions.database = Number redis.db if redis.db
      clientOptions.password = redis.auth if redis.auth

      @redis = Redis.createClient clientOptions
      @_connected = Promise.resolve @redis.connect()

    publish: (notification, value) =>
      Promise.props
        channel: @_getChannel(notification)
        value: @_buildValue_(value)
      .then ({ channel, value }) =>
        @_connected.then => Promise.resolve @redis.publish channel, value

    _getChannel: (notification) =>
      Promise.props
        channelPrefix: @_channelPrefix_ notification.type
        messagePath: @_messagePath_ notification
      .then ({ channelPrefix, messagePath }) => "#{channelPrefix}/#{messagePath}"

    _messagePath_: => throw new Error "not supported `_messagePath_`"
    _buildValue_: => throw new Error "not supported `_buildValue_`"
    _channelPrefix_: (type) => throw new Error "not supported `_channelPrefix_`"

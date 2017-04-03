_ = require "lodash"
moment = require "moment"
Promise = require "bluebird"
RedisObserver = require "./redis.observer"
{ minimal, mild, moderate, high, huge } = require "./delay.levels"

module.exports =
    class DelayObserver extends RedisObserver

      constructor: (redis) ->
        super redis
        @currentDelay = minimal

      listenTo: (emitter) ->
        emitter.on "finished", @finish

      finish: ({ message, meta }) =>
        delay = @_messageDelay meta
        return Promise.resolve() unless delay? and @_delayChanged delay

        @currentDelay = delay
        @publish message, @currentDelay.name

      _messageDelay: (meta) =>
        @_delayByMilliseconds @_millisecondsDelay meta, new Date()

      _millisecondsDelay: ({ insertionTime }, now) =>
        enqueuedTime = moment.utc new Date insertionTime
        moment.utc(now).diff enqueuedTime

      _delayChanged: (newDelay) => !_.isEqual newDelay, @currentDelay

      _delayByMilliseconds: (ms) =>
        delayLevels = [ minimal, mild, moderate, high, huge ]
        _.findLast delayLevels, ({value}) => ms >= value

      _buildValue_ : _.identity

      _channelPrefix_: -> "health-delay-sb"

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

      finish: ({ message }) =>
        delay = @_messageDelay message
        return Promise.resolve() unless delay? and @_delayChanged delay

        @currentDelay = delay
        @publish message, @currentDelay.name

      _messageDelay: (message) =>
        @_delayByMilliseconds @_millisecondsDelay message, new Date()

      _millisecondsDelay: ({ Sent }, now) =>
        enqueuedTime = moment.utc new Date Sent
        moment.utc(now).diff enqueuedTime

      _delayChanged: (newDelay) => !_.isEqual newDelay, @currentDelay

      _delayByMilliseconds: (ms) =>
        delayLevels = [ minimal, mild, moderate, high, huge ]
        _.findLast delayLevels, ({value}) => ms >= value

      _buildValue_ : _.identity

      _channelPrefix_: -> "health-queue-sb"

proxyquire = require "proxyquire"
Promise = require "bluebird"
sinon = require "sinon"
_ = require "lodash"

class MockRedisClient
  constructor: ->
    @refreshSpies()
  auth: ->
  refreshSpies: =>
    @spies = publishAsync: sinon.spy()
  publishAsync: (key,value) ->
    Promise.resolve @spies.publishAsync key, value

stub =
  "../services/redis":
    class MockRedis
      @createClient: -> new MockRedisClient()

proxyquire "../observers/redis.observer", stub

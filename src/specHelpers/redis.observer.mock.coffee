proxyquire = require "proxyquire"
Promise = require "bluebird"
sinon = require "sinon"
_ = require "lodash"

class MockRedisClient
  constructor: ->
    @refreshSpies()
  connect: -> Promise.resolve()
  refreshSpies: =>
    @spies = publish: sinon.spy()
  publish: (key,value) ->
    Promise.resolve @spies.publish key, value

stub =
  "../services/redis":
    class MockRedis
      @createClient: -> new MockRedisClient()

proxyquire "../observers/redis.observer", stub

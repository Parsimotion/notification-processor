require "../specHelpers/redis.observer.mock"
should = require "should"
moment = require "moment"
DelayObserver = require "./delay.observer"
{ redis, notification } = require "../specHelpers/fixture"
{ minimal, mild, moderate, high, huge } = require "./delay.levels"
{ observer } = {}

describe "Delay observer", ->
  beforeEach ->
    observer = new DelayObserver { redis, app: "una-app", path: "un-topic/una-subscription" }

  it "should publish if delay changes", ->
    observer.finish notification
    .then =>
      observer.redis.spies.publishAsync
      .withArgs "health-delay-sb/una-app/un-topic/una-subscription", '"Huge"'
      .calledOnce.should.be.true()

  it "should not publish if delay did not change", ->
    observer.currentDelay = huge
    observer.finish notification
    .then =>
      observer
      .redis.spies.publishAsync
      .notCalled.should.be.true()

  it "should get delay in milliseconds", ->
    enqueuedTime = moment new Date notification.meta.insertionTime
    now = enqueuedTime.add 100, 'ms'
    delay = observer._millisecondsDelay notification.meta, now.toDate()
    delay.should.eql 100

  it "should transform delay in milliseconds to delay object", ->
    anotherMinimal = { value: 10, name: minimal.name }
    anotherMild = { value: 8000, name: mild.name }
    [ minimal, anotherMinimal, mild, anotherMild, moderate, high, huge ].forEach (level) =>
      assertDelay level.value, level.name

assertDelay = (ms, name) =>
  observer._delayByMilliseconds ms
  .name.should.eql name

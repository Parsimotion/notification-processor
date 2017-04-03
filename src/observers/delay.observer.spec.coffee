require "../specHelpers/redis.observer.mock"
should = require "should"
moment = require "moment"
DelayObserver = require "./delay.observer"
{ redis, message } = require "../specHelpers/fixture"
{ minimal, mild, moderate, high, huge } = require "./delay.levels"
{ observer } = {}

describe "Delay observer", ->
  beforeEach ->
    observer = new DelayObserver redis

  it "should publish if delay changes", ->
    observer.finish { message }
    .then =>
      observer
      .redis.spies.publishAsync
      .withArgs "health-queue-sb/una-app/123/un-topic/una-subscription/456", 'Huge'
      .calledOnce.should.be.true()

  it "should not publish if delay did not change", ->
    observer.currentDelay = huge
    observer.finish { message }
    .then =>
      observer
      .redis.spies.publishAsync
      .notCalled.should.be.true()

  it "should get delay in milliseconds", ->
    enqueuedTime = moment new Date message.Sent
    now = enqueuedTime.add 100, 'ms'
    delay = observer._millisecondsDelay message, now.toDate()
    delay.should.eql 100

  it "should transform delay in milliseconds to delay object", ->
    anotherMinimal = { value: 10, name: minimal.name }
    anotherMild = { value: 8000, name: mild.name }
    [ minimal, anotherMinimal, mild, anotherMild, moderate, high, huge ].forEach (level) =>
      assertDelay level.value, level.name

assertDelay = (ms, name) =>
  observer._delayByMilliseconds ms
  .name.should.eql name

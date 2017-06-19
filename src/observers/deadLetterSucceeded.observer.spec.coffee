require "../specHelpers/redis.observer.mock"

{ redis, notification } = require "../specHelpers/fixture"

DeadLetterSucceeded = require "./deadLetterSucceeded.observer"
Sender = require "../senders/producteca.sender"

should = require "should"
require "should-sinon"

describe "Dead Letter Succeeded observer", ->

  { observer } = {}

  beforeEach ->
    observer = new DeadLetterSucceeded { redis, app: "una-app", path: "un-topic/una-subscription", sender: Sender }

  it "should publish if a dead letter message runs successfully", ->
    observer.success { notification }
    .then =>
      observer.redis.spies.publishAsync
      .should.be.calledOnce()
      .and
      .calledWith "health-message-sb/una-app/123/un-topic/una-subscription/456", JSON.stringify success:true

require "../specHelpers/redis.observer.mock"

{ redis, notification } = require "../specHelpers/fixture"

_ = require "lodash"
should = require "should"
require "should-sinon"

DidLastRetry = require "./didLastRetry.observer"
Sender = require "../senders/producteca.sender"

describe "Did Last Retry observer", ->

  { observer } = {}

  beforeEach ->
    observer = new DidLastRetry { redis, app: "una-app", path: "un-topic/una-subscription", sender: Sender }

  it "should publish if a failed mesasge is on its last retry", ->
    error = "hubo un error"
    lastRetry = _.merge {}, notification, meta: dequeueCount: 5
    observer.error { notification: lastRetry , error }
    .then =>
      observer
      .redis.spies.publishAsync
      .should.be.calledOnce()
      .and
      .calledWith "health-message-sb/una-app/123/un-topic/una-subscription/456", JSON.stringify { "success":false, "error":"hubo un error" }

  it "should not publish if a failed message is not on its last retry", ->
    observer.error { notification }
    .then =>
      observer.redis.spies.publishAsync.should.be.not.called()


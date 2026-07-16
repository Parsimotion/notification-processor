_ = require "lodash"
NonRetryableError = require "./exceptions/non.retryable"
ProcessorBuilder = require "./processor.builder"
should = require "should"
Promise = require "bluebird"

azureContext = -> log: console.log

createProcessor = (fn) ->
  ProcessorBuilder.create()
    .withFunction fn
    .build()

doWith = (fn) ->
  createProcessor fn
  .process azureContext(), {}

describe "Promise - Processor", ->

  context "use a synchronous function", ->

    it "Returns a successful promise", ->
      doWith(-> true).should.be.fulfilled()

    it "Returns a unsuccessful promise", ->
      doWith(-> throw new Error).should.be.rejected()

  context "use an asynchronous function", ->

    it "Returns a successful promise", ->
      doWith(-> Promise.resolve true).should.be.fulfilled()

    it "Returns a unsuccessful promise", ->
      doWith(-> Promise.reject new Error).should.be.rejected()

    it "Returns a successful promise if non retriable error", ->
      doWith(-> Promise.reject new NonRetryableError).should.be.fulfilled()

  describe "using timeout", ->

    { processor } = { }

    beforeEach ->
      processor = createProcessor -> Promise.delay 25

    it "should success if processor is resolved before timeout", ->
      processor.timeout = 50
      processor.process(azureContext(), {}).should.be.fulfilled()

    it "should fail if processor is resolved after timeout", ->
      processor.timeout = 10
      processor.process(azureContext(), {}).should.be.rejected()

_ = require "lodash"
NonRetryableError = require "./exceptions/non.retryable"
ProcessorBuilder = require "./processor.builder"
should = require "should"
Promise = require "bluebird"

statusAsync = (expectedStatus, done) -> (err) ->
  resolved = not err?
  if resolved is expectedStatus then done() else done "Async failed: expected=#{expectedStatus}, resolved=#{resolved}"

azureContext = (verifier) ->
  log: console.log
  done: verifier

createProcessor = (fn) ->
  ProcessorBuilder.create()
    .withFunction fn
    .build()

doWith = (verifier, fn) ->
  createProcessor fn
  .process {}, azureContext(verifier)

describe "Promise - Processor", ->

  context "use a synchronous function", ->

    it "Returns a successful promise", (done) ->
      doWith statusAsync(true, done), -> true

    it "Returns a unsuccessful promise", (done) ->
      doWith statusAsync(false, done), -> throw new Error

  context "use an asynchronous function", ->

    it "Returns a successful promise", (done) ->
      doWith statusAsync(true, done), -> Promise.resolve true

    it "Returns a unsuccessful promise", (done) ->
      doWith statusAsync(false, done), -> Promise.reject new Error

    it "Returns a successful promise if non retriable error", (done) ->
      doWith statusAsync(true, done), -> Promise.reject new NonRetryableError

  describe "using timeout", ->

    { processor } = { }

    beforeEach ->
      processor = createProcessor -> Promise.delay 25

    it "should success if processor is resolved before timeout", (done) ->
      processor.timeout = 50
      processor.process {}, azureContext(statusAsync(true, done))

    it "should fail if processor is resolved after timeout", (done) ->
      processor.timeout = 10
      processor.process {}, azureContext(statusAsync(false, done))

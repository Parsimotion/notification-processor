_ = require "lodash"
ProcessorBuilder = require "./processorBuilder"
should = require "should"

statusAsync = (expectedStatus, done) -> (err) ->
  resolved = not err?
  if resolved is expectedStatus then done() else done "Async failed: expected=#{expectedStatus}, resolved=#{resolved}"

azureContext = (verifier) ->
  log: console.log
  done: verifier

doWith = (verifier, fn) ->
  ProcessorBuilder.create()
    .withFunction fn
    .build()
    .process azureContext(verifier), {}

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

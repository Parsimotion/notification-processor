nock = require "nock"
should = require "should"
sinon = require "sinon"
require "should-sinon"
errors = require "request-promise/errors";

RequestProcessor = require "./request.processor"

DOMAIN = "http://miApi.com.foo"
PATH = "/api/availableQuantity/123"
MESSAGE =
  sku: "123"

describe "RequestProcessor", ->

  before ->
    nock.disableNetConnect()

  afterEach ->
    nock.cleanAll()

  after ->
    nock.enableNetConnect()

  it "should do a POST request and its should be successful", ->
    nockDomain = nockStub().reply 200, {}
    spy = sinon.spy RequestProcessor req

    spy MESSAGE
    .should.be.fulfilled()
    .tap -> nockDomain.done()
    .tap -> spy.should.be.calledWith MESSAGE

  it "should do a POST request and its should be unsuccessful", ->
    nockDomain = nockStub().reply 503, {}
    spy = sinon.spy RequestProcessor req

    spy MESSAGE
    .should.be.rejected()
    .tap -> nockDomain.done()
    .tap -> spy.should.be.calledWith MESSAGE

  it "should do a POST request and its should be ignored if is a silent errors", ->
    nockDomain = nockStub().reply 409, {}
    spy = sinon.spy RequestProcessor req, { silentErrors: [ 409 ] }

    spy MESSAGE
    .should.be.fulfilled()
    .tap -> nockDomain.done()
    .tap -> spy.should.be.calledWith MESSAGE

req = ->
  url: "#{DOMAIN}#{PATH}"
  method: "POST"

nockStub = ->
   nock(DOMAIN).post PATH

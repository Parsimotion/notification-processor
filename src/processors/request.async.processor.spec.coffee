_ = require "lodash"
nock = require "nock"
AsyncProcessor = require "./request.async.processor"

DOMAIN = "http://miApi.com.foo"
PATH = "/api/availableQuantity/123"
BEARER = "Bearer lala"
MESSAGE = {
  message: {
    Method: "POST"
    Resource: PATH
    HeadersForRequest: [
      {
        Key: "Authorization",
        Value: BEARER
      }
    ]
  }
}

describe "RequestAsyncProcessor", ->
  
  { processor, nockStub } = {}

  before ->
    nock.disableNetConnect()
    processor = AsyncProcessor { apiUrl: DOMAIN }

  beforeEach ->
    nockStub = nock(DOMAIN, {
      reqheaders: { Authorization: BEARER }
    }).post PATH

  afterEach ->
    nock.cleanAll()

  after ->
    nock.enableNetConnect()

  it "should do a POST request and its should be successful", ->
    nockDomain = nockStub.reply 200, {}
    
    processor MESSAGE
    .should.be.fulfilled()
    .tap -> nockDomain.done()

  it "should do a POST request and its should be unsuccessful", ->
    nockDomain = nockStub.reply 503, {}

    processor MESSAGE
    .should.be.rejected()
    .tap -> nockDomain.done()


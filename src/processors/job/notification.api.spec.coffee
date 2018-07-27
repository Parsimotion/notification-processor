_ = require "lodash"
NOTIFICATIONS_URL = "http://notifications-api-development.azurewebsites.net/api"
_.assign process.env, NOTIFICATIONS_API_URL: NOTIFICATIONS_URL

nock = require "nock"
should = require "should"
require "should-sinon"

NotificationsApi = require "./notification.api"

describe "NotificationsApi", ->

  notificationsApi = new NotificationsApi "randomAccessToken"

  it "on success: should send success: true to notificationsApi", ->
    jobId = 1
    statusCode = 202
    bodyExpected = { statusCode, success: yes }

    nock(NOTIFICATIONS_URL)
    .post "/jobs/#{jobId}/operations", (body) -> body.should.be.eql bodyExpected
    .reply(200)

    notificationsApi.success { message: { jobId }, statusCode }

  it "on fail: should send success: false with error message to notificationsApi", ->
    jobId = 1
    statusCode = 400
    message = "Opps!, Something went wrong"
    request = request: { method: "POST", url: "/items" }
    bodyExpected = { statusCode, message, success: no, request }

    nock(NOTIFICATIONS_URL)
    .post "/jobs/#{jobId}/operations", (body) -> body.should.be.eql bodyExpected
    .reply(200)

    notificationsApi.fail { message: { jobId } , statusCode, error: { message }, request }

  it "ignore error if its has ocurred when call to notifications-api", ->
    @timeout 4000
    jobId = "123"

    nock(NOTIFICATIONS_URL)
    .post "/jobs/#{jobId}/operations"
    .times 3
    .reply 500

    notificationsApi.success { message: { jobId }, statusCode: 200 }

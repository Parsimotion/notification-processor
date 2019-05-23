_ = require "lodash"
nock = require "nock"
should = require "should"
require "should-sinon"
NotificationsApi = require "./notification.api"

NOTIFICATIONS_URL = "http://notifications-api-development.azurewebsites.net/api"
JOB_ID = 1

describe "NotificationsApi", ->

  notificationsApi = new NotificationsApi {
    notificationApiUrl: NOTIFICATIONS_URL
    token: "randomAccessToken"
    jobId: JOB_ID
  }

  it "on success: should send success: true to notificationsApi", ->
    statusCode = 202
    bodyExpected = { statusCode, success: yes }

    nock(NOTIFICATIONS_URL)
    .post "/jobs/#{ JOB_ID }/operations", (body) -> body.should.be.eql bodyExpected
    .reply(200)

    notificationsApi.success { message: { }, statusCode }

  it "on fail: should send success: false with error message to notificationsApi", ->
    statusCode = 400
    message = "Opps!, Something went wrong"
    request = request: { method: "POST", url: "/items" }
    bodyExpected = { statusCode, message, success: no, request }

    nock(NOTIFICATIONS_URL)
    .post "/jobs/#{ JOB_ID }/operations", (body) -> body.should.be.eql bodyExpected
    .reply(200)

    notificationsApi.fail { message: { } , statusCode, error: { message }, request }

  it "ignore error if its has ocurred when call to notifications-api", ->
    @timeout 4000

    nock(NOTIFICATIONS_URL)
    .post "/jobs/#{ JOB_ID }/operations"
    .times 3
    .reply 500

    notificationsApi.success { message: { }, statusCode: 200 }

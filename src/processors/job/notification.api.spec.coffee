_ = require "lodash"
NOTIFICATIONS_URL = "http://notifications-api-development.azurewebsites.net/api"
_.assign process.env, NOTIFICATIONS_API_URL: NOTIFICATIONS_URL

nock = require "nock"
should = require "should"
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

    notificationsApi.success(jobId, statusCode)

  it "on fail: should send success: false with error message to notificationsApi", ->
    jobId = 1
    statusCode = 400
    message = "Opps!, Something went wrong"
    bodyExpected = { statusCode, message, success: no }

    nock(NOTIFICATIONS_URL)
    .post "/jobs/#{jobId}/operations", (body) -> body.should.be.eql bodyExpected
    .reply(200)

    notificationsApi.fail(jobId, statusCode, { message })

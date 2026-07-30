process.env.CDM_FORCE_REGISTER_STATUS_CODES = "409,422"

require "should"
MonitoringCenterRegisterAllObserver = require "./monitoringCenterRegisterAll.observer"

_buildObserver = ->
  new MonitoringCenterRegisterAllObserver {
    sender: {}
    clientId: "1"
    app: "app"
    job: "job"
    connection:
      accessKeyId: "unAccessKeyId"
      secretAccessKey: "unSecretAccessKey"
      deliveryStream: "unDeliveryStream"
      jobsDeliveryStream: "unJobsDeliveryStream"
      region: "us-east-1"
  }

describe "MonitoringCenterRegisterAllObserver", ->

  describe "_shouldSkipByStatusCode", ->
    observer = _buildObserver()

    it "should never skip, even without an error", ->
      observer._shouldSkipByStatusCode(undefined).should.be.false()

    it "should never skip a statusCode outside CDM_FORCE_REGISTER_STATUS_CODES", ->
      observer._shouldSkipByStatusCode({ statusCode: 500 }).should.be.false()

    it "should never skip a statusCode inside CDM_FORCE_REGISTER_STATUS_CODES", ->
      observer._shouldSkipByStatusCode({ statusCode: 409 }).should.be.false()

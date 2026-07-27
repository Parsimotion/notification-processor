process.env.CDM_FORCE_REGISTER_STATUS_CODES = "409,422"

should = require "should"
MonitoringCenterObserver = require "./monitoringCenter.observer"

_buildObserver = ->
  new MonitoringCenterObserver {
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

describe "MonitoringCenterObserver", ->

  describe "_shouldSkipByStatusCode", ->
    observer = _buildObserver()

    it "should not skip when there is no error", ->
      should(observer._shouldSkipByStatusCode(undefined)).not.be.ok()

    it "should not skip when the error has no statusCode", ->
      should(observer._shouldSkipByStatusCode({ message: "error" })).not.be.ok()

    it "should skip when the statusCode is not in CDM_FORCE_REGISTER_STATUS_CODES", ->
      observer._shouldSkipByStatusCode({ statusCode: 500 }).should.be.true()

    it "should not skip (forces register) when the statusCode is in CDM_FORCE_REGISTER_STATUS_CODES", ->
      observer._shouldSkipByStatusCode({ statusCode: 409 }).should.be.false()

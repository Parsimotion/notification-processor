MonitoringCenterObserver = require "./monitoringCenter.observer"

module.exports =
  class MonitoringCenterRegisterAllObserver extends MonitoringCenterObserver
    _shouldSkipByStatusCode: (error) -> false

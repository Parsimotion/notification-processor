_ = require("lodash")

redis =
  host: "127.0.0.1"
  port: "1234"
  db: "3"
  auth: "unaCadenaDeAuth"

notification =
  type: "sb"
  dequeueCount: 1
  message:
    CompanyId: 123
    ResourceId: 456
  meta:
    insertionTime: "Sat, 05 Nov 2016 16:44:43 GMT"

module.exports = {
  redis
  notification
}

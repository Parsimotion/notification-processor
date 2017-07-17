azureTable = require "azure-table-node"
Promise = require "bluebird"

module.exports =
  ({ connection, table = "poison", name, rowKeyGenerator, maxDequeueCount = 1 }, processor) ->
    client = Promise.promisifyAll azureTable.createClient(azureTable.parseAccountString(connection)), multiArgs: true
    (notification) ->
      if notification.meta.dequeueCount >= maxDequeueCount
        client.insertOrReplaceEntityAsync(table, {
          PartitionKey: encodeURIComponent name
          RowKey: encodeURIComponent rowKeyGenerator notification.message
          notification: JSON.stringify notification
        })
      else
        processor notification

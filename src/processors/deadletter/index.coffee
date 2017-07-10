azureTable = require "azure-table-node"
Promise = require "bluebird"

module.exports =
  ({ connection, table = "poison", name, rowKeyGenerator, maxDequeueCount = 5 }, processor) ->
    client = Promise.promisifyAll azureTable.createClient(azureTable.parseAccountString(connection)), multiArgs: true
    (notification) ->
      processor(notification).catch (err) ->
        throw err unless notification.meta.dequeueCount > maxDequeueCount
        client.insertOrReplaceEntityAsync(table, {
          PartitionKey: encodeURIComponent name
          RowKey: encodeURIComponent rowKeyGenerator notification.message
          notification: JSON.stringify notification
        })

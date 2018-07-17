azureTable = require "azure-table-node"
Promise = require "bluebird"

MaxRetriesProcessor = require("../maxRetries.processor")

module.exports = 
  class DeadletterProcessor extends MaxRetriesProcessor

    constructor: (args) ->
      super args
      @table = args.storage.table 
      @name = args.storage.name
      @rowKeyGenerator = args.storage.rowKeyGenerator
      @client = @_buildClient azureTable.parseAccountString args.storage.connection
      
    _onSuccess_: (notification, result) ->
    
    _sanitizeError_: (err) -> err
    
    _onMaxRetryExceeded_: (notification, err) -> 
      @client.insertOrReplaceEntityAsync @table, {
        PartitionKey: encodeURIComponent @name
        RowKey: encodeURIComponent @rowKeyGenerator notification.message
        notification: JSON.stringify notification
      }

    _buildClient: (connection) ->
      Promise.promisifyAll azureTable.createClient(connection), multiArgs: true

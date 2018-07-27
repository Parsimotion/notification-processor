azureTable = require "azure-table-node"
Promise = require "bluebird"

MaxRetriesProcessor = require("../maxRetries.processor")

module.exports = 
  class DeadletterProcessor extends MaxRetriesProcessor

    constructor: (args) ->
      super args
      { @sender, storage: { @table, @name, connection }} = args
      @client = @_buildClient azureTable.parseAccountString args.storage.connection
      
    _onSuccess_: (notification, result) ->
    
    _sanitizeError_: (err) -> err
    
    _onMaxRetryExceeded_: (notification, err) ->
      @client.insertOrReplaceEntityAsync @table, {
        PartitionKey: encodeURIComponent @name
        RowKey: encodeURIComponent @sender.resource notification
        user: encodeURIComponent @sender.user notification
        notification: JSON.stringify notification
        error: JSON.stringify err
        type: _.get(err, "message") or "unknown_error"
      }

    _buildClient: (connection) ->
      Promise.promisifyAll azureTable.createClient(connection), multiArgs: true

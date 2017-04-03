__ = require "lodash/fp"
requireDirectory = require "require-directory"

requireDir = (path) ->
  requireDirectory module, path, {
    recurse: false
    exclude: /spec/
    rename: __.compose __.upperFirst, __.camelCase
  }

module.exports =
  Builder: require "./processor.builder"
  Observers: requireDir "./observers"
  Processors: requireDir "./processors"

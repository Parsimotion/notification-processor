__ = require "lodash/fp"
requireDirectory = require "require-directory"

module.exports =
  Builder: require "./processor.builder"
  Observers: requireDirectory module, "./observers", {
    recurse: false
    exclude: /spec/
    rename: __.compose __.upperFirst, __.camelCase
  }

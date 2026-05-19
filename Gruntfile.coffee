"use strict"

require("coffeescript/register")

module.exports = (grunt) ->

  #-------
  #Plugins
  #-------
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-mocha-test"
  grunt.loadNpmTasks "grunt-bump"
  grunt.loadNpmTasks "grunt-exec"

  #-----
  #Tasks
  #-----
  grunt.registerTask "default", "build"
  grunt.registerTask "test", "mochaTest"
  grunt.registerTask "build", ["clean:build", "exec:compile", "exec:copyJs", "clean:specs"]

  #------
  #Config
  #------
  grunt.initConfig
    #Clean build directory
    clean:
      build: src: "lib"
      specs: src: "lib/**/*.spec.js"

    #Compile coffee
    exec:
      compile: cmd: "./node_modules/coffeescript/bin/coffee --compile --output lib/ src/"
      copyJs: cmd: "cp src/uuid-cjs.js lib/uuid-cjs.js"

    # Run tests
    mochaTest:
      options:
        reporter: "spec"
      src: ["src/**/*.spec.coffee"]

    # Upgrade the version of the package
    bump:
      options:
        files: ["package.json"]
        commit: true
        commitMessage: "Release v%VERSION%"
        commitFiles: ["--all"]
        createTag: true
        tagName: "%VERSION%"
        tagMessage: "Version %VERSION%"
        push: false

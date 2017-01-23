fs = require 'fs'
appConfig = require './assets/config.json'
requirejsTemplate = require 'grunt-template-jasmine-requirejs'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-autoshot'
  grunt.loadNpmTasks 'grunt-image-embed'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-pug'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-html-smoosher-install-fix'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-autoprefixer'
  grunt.loadNpmTasks 'grunt-lesslint'

  grunt.initConfig
    pkg: require './package.json'
    component: require './bower.json'

    clean:
      dist   : ['dist']
      build  : ['build']
      staging: ['build/css/staging']

    uglify:
      dist:
        src: 'assets/js/framework/*.js'
        dest: 'assets/js/js.min.js'

    pug:
      compile:
        options:
          data: appConfig
          pretty: true
        files:
          'build/html/main.html': ['assets/main.pug']
          'build/html/index.html': ['assets/index.pug']
      release:
        options:
          data: appConfig
          pretty: false
        files:
          'build/html/main.html': ['assets/main.pug']
          'build/html/index.html': ['assets/index.pug']

    requirejs:
      css: options:
        out: 'build/css/main.css'
        cssIn: 'build/css/main.css'
        optimizeCss: 'standard'

    less:
      main:
        files:
          'build/css/staging/main.css': 'assets/less/framework/main.less'

    autoprefixer:
      single_file:
        src: 'build/css/main.css'
        dest: 'build/css/main.css'

    copy:
      staging:
        files: [{
          expand: true
          cwd: 'assets/fonts/'
          src: ['*']
          dest: 'build/css/fonts/'
        }]

    imageEmbed:
      dist:
        src: ['build/css/staging/main.css']
        dest: 'build/css/main.css'
        options:
          deleteAfterEncoding : false

    smoosher:
      main:
        files:
          'dist/main.html': 'build/html/main.html'
          'dist/index.html': 'build/html/index.html'

    autoshot:
      normal:
        options:
          path: 'dist/'
          local:
            path: 'build/html/'
            port: 9002
            files: [{
              src: 'main.html'
              dest: 'main.png'
            }]

    lesslint:
      src: 'assets/less/**/*.less'

    watch:
      options:
        livereload: true
      config:
        files: ['assets/config.json']
        tasks: ['pug']
      js:
        files: ['assets/js/**/*.js']
        tasks: ['requirejs', 'default']
      less:
        files: ['assets/less/**/*.less']
        tasks: ['default']
      templates:
        files: ['assets/**/*.pug']
        tasks: ['pug:compile']

    connect:
      server:
        options:
          port: 3333
          livereload: true
          # base: 'build'

    bump:
      options:
        push: false
        commit: false
        createTag: false
        files: ['package.json', 'bower.json']
        updateConfigs: ['pkg', 'component']

  grunt.registerTask 'default', [
    'clean:build'
    'uglify:dist'
    'pug:compile'
    'css'
  ]

  grunt.registerTask 'css', [
    'clean:staging'
    'less'
    'copy:staging'
    'imageEmbed'
    'autoprefixer'
  ]

  grunt.registerTask 'live', [
    'default'
    'connect'
    'watch'
  ]

  grunt.registerTask 'image', [
    'default'
    'autoshot:normal'
  ]

  grunt.registerTask 'dist', [
    'default'
    'pug:release'
    'requirejs:css'
    'clean:dist'
    'smoosher'
  ]

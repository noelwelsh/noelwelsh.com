#global module:false

"use strict"

module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-bower-task"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-exec"

  grunt.initConfig
    less:
      screen:
        options:
          paths: [
            "bower_components/bootstrap/less"
            "_assets/css"
          ]
          yuicompress: true
        files:
          "assets/css/main.min.css": "assets/_less/main.less"

    uglify:
      site:
        files:
          "assets/js/site.js": [
            "bower_components/jquery/jquery.js"
            "bower_components/bootstrap/js/collapse.js"
            "bower_components/bootstrap/js/scrollspy.js"
            "bower_components/bootstrap/js/button.js"
            "bower_components/bootstrap/js/affix.js"
            "bower_components/respond/respond.src.js"
          ]

    copy:
      bootstrap:
        files: [{
          expand: true
          cwd: "bower_components/bootstrap/img/"
          src: ["**"]
          dest: "assets/img/"
        }]

    exec:
      install:
        cmd: "bundle install"
      jekyll:
        cmd: "bundle exec jekyll build --trace --drafts"
      deploy:
        cmd: 'rsync --progress -a --delete -e "ssh -q" _site/ admin@noelwelsh.com:/srv/noelwelsh.com/public/htdocs/'

    bower:
      install: {}

    watch:
      options:
        livereload: true
      css:
        files: [
          "assets/_Less/**/*"
        ]
        tasks: [
          "less"
          "exec:jekyll"
        ]
      js:
        files: [
          "assets/js/**/*"
        ]
        tasks: [
          "uglify"
          "exec:jekyll"
        ]
      html:
        files: [
          "_config.yml"
          "*.md" 
          "_includes/**/*"
          "_layouts/**/*"
          "_plugins/**/*"
          "_posts/**/*"
          "_drafts/**/*"
        ]
        tasks: [
          "copy"
          "exec:jekyll"
        ]

    connect:
      server:
        options:
          port: 4000
          base: '_site'

  grunt.registerTask "build", [
    "less"
    "uglify"
    "copy"
    "exec:jekyll"
  ]

  grunt.registerTask "serve", [
    "build"
    "connect:server"
    "watch"
  ]

  grunt.registerTask "deploy", [
    "build"
    "exec:deploy"
  ]

  grunt.registerTask "default", [
    "serve"
  ]

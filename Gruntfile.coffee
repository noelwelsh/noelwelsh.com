#global module:false
module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig
    less: 
      production: 
        options: 
          paths: ["bower_components/bootstrap/less"]
          yuicompress: true
        files: 
          "assets/css/main.min.css": "assets/_less/main.less"
    uglify: 
      jquery: 
        files: 
          'assets/js/jquery.min.js': 'bower_components/jquery/jquery.js'
      bootstrap: 
        files: 
          'assets/js/bootstrap.min.js': ['bower_components/bootstrap/js/collapse.js',
                                         'bower_components/bootstrap/js/scrollspy.js',
                                         'bower_components/bootstrap/js/button.js',
                                         'bower_components/bootstrap/js/affix.js']
      mailchimp:
        files:
          'assets/js/mailchimp.min.js' : 'assets/js/mailchimp.js'
    copy: 
      bootstrap: 
        files: [
          {expand: true, cwd: 'bower_components/bootstrap/img/', src: ['**'], dest: 'assets/img/'}
        ]
    exec: 
      build: 
        cmd: 'jekyll build'
      serve: 
        cmd: 'jekyll serve --watch --drafts'
      deploy: 
        cmd: 'rsync --progress -a --delete -e "ssh -q" _site/ admin@unweb.com:/srv/noelwelsh.com/public/htdocsg/'
    bower: 
      install: {}

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-exec');
  grunt.loadNpmTasks('grunt-bower-task');
   
  grunt.registerTask('default', [ 'less', 'uglify', 'copy', 'exec:serve' ]);
  grunt.registerTask('deploy', [ 'less', 'uglify', 'copy', 'exec:build', 'exec:deploy' ]);


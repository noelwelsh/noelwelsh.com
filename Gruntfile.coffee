#global module:false
module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig
    less: 
      production: 
        options: 
          paths: ["components/bootstrap/less"]
          yuicompress: true
        files: 
          "assets/css/main.min.css": "assets/_less/main.less"
    uglify: 
      jquery: 
        files: 
          'assets/js/jquery.min.js': 'components/jquery/jquery.js'
      bootstrap: 
        files: 
          'assets/js/bootstrap.min.js': ['components/bootstrap/js/collapse.js',
                                         'components/bootstrap/js/scrollspy.js',
                                         'components/bootstrap/js/button.js',
                                         'components/bootstrap/js/affix.js']
    copy: 
      bootstrap: 
        files: [
          {expand: true, cwd: 'components/bootstrap/img/', src: ['**'], dest: 'assets/img/'}
        ]
    exec: 
      build: 
        cmd: 'jekyll build'
      serve: 
        cmd: 'jekyll serve --watch'
      deploy: 
        cmd: 'rsync --progress -a --delete -e "ssh -q" _site/ myuser@host:mydir/'
    bower: 
      install: {}

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-exec');
  grunt.loadNpmTasks('grunt-bower-task');
   
  grunt.registerTask('default', [ 'less', 'uglify', 'copy', 'exec:serve' ]);
  grunt.registerTask('deploy', [ 'default', 'exec:deploy' ]);


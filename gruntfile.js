module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

  watch: {
    scripts: {
      files: ['app/*.html', 'app/*.coffee'],
      tasks: ['default'],
      options: {
        spawn: false,
      }
    }
  },

    coffeelint: {
      options: {
        configFile: 'coffeelint.json'
      },
      app: ['app/*.coffee']
    },
    coffee: {
      compile: {
        files: {
          'tmp/asteroids.js': 'app/*.coffee'
        }
      }
    },
    concat: {
      dist: {
        src: ['vendor/rAF.js',
              'bower_components/es6-promise/promise.js',
              'bower_components/jquery/dist/jquery.js',
              'bower_comonents/bootstrap/dist/js/bootstrap.js',
              'tmp/asteroids.js'],
        dest: 'tmp/asteroids.js'
      }
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      build: {
        src: 'tmp/asteroids.js',
        dest: 'dist/asteroids.min.js'
      }
    },
    copy: {
      main: {
        files: [
          { src: ['bower_components/bootstrap/dist/css/bootstrap.min.css'], dest: 'dist/style.css' },
          { src: ['**/*'], cwd: 'app/assets/images', expand: true, flatten: true, dest: 'dist/images/' },
          { src: ['app/index.html'], dest: 'dist/index.html' }
        ]
      }
    },
    uncss: {
      dist: {
        files: {
          'dist/style.css': ['dist/index.html']
        }
      }
    },

    cssmin: {
      my_target: {
        files: [{
          expand: true,
          cwd: 'dist/',
          src: ['*.css', '!*.min.css'],
          dest: 'dist/',
          ext: '.css'
        }]
      }
    }
  });

  // Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-uncss');
  grunt.loadNpmTasks('grunt-contrib-cssmin');

  // Default task(s).
  // grunt.registerTask('default', ['uglify']);
  grunt.registerTask('default', ['coffeelint', 'coffee', 'concat', 'uglify', 'copy', 'uncss', 'cssmin']);
};

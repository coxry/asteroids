module.exports = function(grunt) {
  grunt.loadNpmTasks("grunt-es6-module-transpiler");
  grunt.loadNpmTasks("grunt-contrib-concat");
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-uncss');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.initConfig({

   coffeelint: {
      options: {
        configFile: 'coffeelint.json'
      },
      app: ['app/*.coffee']
    },

    coffee: {
      options: {
        bare: true
      },
      compile: {
        files: [{
          expand: true,
          cwd: 'app/',
          src: ['**/*.coffee'],
          dest: 'tmp/',
          ext: '.js'
        }]
      }
    },

    transpile: {
      amd: {
        type: 'amd',
        files: [{
          expand: true,
          cwd: 'tmp/',
          src: ['**/*.js'],
          dest: 'tmp/',
          ext: '.amd.js'
        }]
      },

      // commonjs: {
      //   type: 'cjs',
      //   files: [{
      //     expand: true,
      //     cwd: 'tmp/',
      //     src: ['asteroids/*.coffee.js'],
      //     dest: 'dist/commonjs/',
      //     ext: '.js'
      //   },
      //   {
      //     src: ['tmp/asteroids.coffee.js'],
      //     dest: 'dist/commonjs/main.js'
      //   }]
      // }
    },

    concat: {
      amd: {
        src: ["vendor/rAF.js",
              "bower_components/es6-promise/promise.js",
              "tmp/**/*.amd.js"],
        dest: "dist/asteroids.amd.js"
      },
    },

    browser: {
      dist: {
        src: ["vendor/loader.js", "dist/asteroids.amd.js"],
        dest: "dist/asteroids.js",
        options: {
          barename: "asteroids",
          namespace: "asteroids"
        }
      }
    },

    uglify: {
      options: {
        sourceMap: true
      },
      build: {
        src: 'dist/asteroids.js',
        dest: 'dist/asteroids.min.js'
      }
    },

    copy: {
      main: {
        files: [
          { src: ['bower_components/bootstrap/dist/css/bootstrap.min.css'], dest: 'dist/style.css' },
          { src: ['**/*'], cwd: 'assets/images', expand: true, flatten: true, dest: 'dist/images/' },
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
    },

    watch: {
      scripts: {
        files: ['style/**/*.css', 'app/**/*.coffee'],
        tasks: ['default'],
        options: {
          spawn: false,
        }
      }
    }

  });

  grunt.loadTasks('tasks');
  grunt.registerTask("default", ["coffeelint", "coffee", "transpile", "concat:amd", "browser", "uglify", "copy", "uncss", "cssmin"]);
}

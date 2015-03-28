module.exports = config =
  port: 3000
  livereload: 35729
  env: \development

  server: \./server

  jade-locals: {}

  src:
    browserify:      \./client/scripts.ls
    views:           \client/views/**/*.jade
    component-views: \client/components/**/*.jade
    styles:          \client/styles/**/*.styl

  dest:
    root:            \_build
    browserify:      \_build/scripts.js
    views:           \_build
    component-views: \_build/components
    styles:          \_build/styles

config.jade-locals.livereload = config.livereload

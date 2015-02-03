module.exports =
  port: 3000
  livereload: 35729

  server: \./server

  src:
    browserify:      \./client/scripts.ls
    views:           \client/views/**/*.jade
    component-views: \client/components/**/*.jade
    styles:          \client/styles/**/*.styl

  dest:
    root:            \client/build
    browserify:      \client/build/scripts.js
    views:           \client/build
    component-views: \client/build/components
    styles:          \client/build/styles

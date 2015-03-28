require! \./config

require! <[ gulp gulp-util gulp-watch gulp-live-server gulp-livescript gulp-stylus gulp-jade ]>
require! <[ browserify watchify vinyl-source-stream vinyl-buffer del ]>

node-env = config.env ? \development

function browserify-bundle-handler(bundle)
  bundle
    .on \error, gulp-util.log.bind gulp-util, "Browserify error"
    .pipe vinyl-source-stream config.dest.browserify
    .pipe gulp.dest \.

gulp.task \browserify, ->
  browserify-bundle-handler browserify(config.src.browserify).bundle!

gulp.task \watchify, ->
  bundler = watchify browserify config.src.browserify, watchify.args
    .on \update, -> browserify-bundle-handler bundler.bundle!
    .on \time, (time) -> gulp-util.log "Browserify finished after #time ms"
  browserify-bundle-handler bundler.bundle!

function generate-build-task(name, key, pipe)
  gulp.task name, ->
    gulp.src config.src[key]
      .pipe pipe
      .pipe gulp.dest config.dest[key]

  gulp.task "#name:watch", ->
    gulp.src config.src[key]
      .pipe gulp-watch config.src[key], verbose: true
      .pipe pipe
      .pipe gulp.dest config.dest[key]

generate-build-task \views, \views,
  gulp-jade {locals: config.jade-locals}
generate-build-task \component-views, \componentViews,
  gulp-jade {locals: config.jade-locals}
generate-build-task \styles, \styles,
  gulp-stylus!

gulp.task \clean, (cb) ->
  del [config.dest.root + \/**], cb


gulp.task \build, <[ clean browserify views component-views styles ]>
gulp.task \default <[ build ]>

gulp.task \watch, <[ watchify views:watch component-views:watch styles:watch ]>, ->

gulp.task \server, ->
  server = gulp-live-server [config.server], {env: NODE_ENV: node-env}, config.livereload
  server.start!

  gulp.start \watch

  # Restart server on changes
  gulp-watch [
    "#{config.server}/**/*.{js,ls}"
    "gulpfile.ls"
    "config.ls"
  ], (event) ->
    gulp-util.log "Server changed:", event.path
    server.start event

  # Trigger LiveReload on client asset changes
  gulp-watch config.dest.root + "/**/*.{js,html,css}", server.notify

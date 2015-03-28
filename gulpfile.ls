require! \./config

require! <[ gulp gulp-util gulp-live-server gulp-livescript gulp-stylus gulp-jade ]>
require! <[ browserify watchify vinyl-source-stream vinyl-buffer del ]>

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

gulp.task \views, ->
  gulp.src config.src.views
    .pipe gulp-jade {locals: config.jade-locals}
    .pipe gulp.dest config.dest.views

gulp.task \component-views, ->
  gulp.src config.src.component-views
    .pipe gulp-jade {locals: config.jade-locals}
    .pipe gulp.dest config.dest.component-views

gulp.task \styles, ->
  gulp.src config.src.styles
    .pipe gulp-stylus!
    .pipe gulp.dest config.dest.styles

gulp.task \clean, (cb) ->
  del [config.dest.root + \/**], cb


gulp.task \build, <[ clean browserify views component-views styles ]>
gulp.task \default <[ build ]>

gulp.task \watch, <[ watchify ]>, ->
  gulp.watch config.src.views, <[ views ]>
  gulp.watch config.src.component-views, <[ component-views ]>
  gulp.watch config.src.styles, <[ styles ]>

gulp.task \server, <[ build watch ]>, ->
  env = NODE_ENV: config.env ? \development
  server = gulp-live-server [config.server], {env}, config.livereload
  server.start!

  # Restart server on changes
  gulp.watch [
    "#{config.server}/**/*.{js,ls}"
    "gulpfile.ls"
    "config.ls"
  ], (event) ->
    gulp-util.log "Server changed:", event.path
    server.start event

  # Trigger LiveReload on client asset changes
  gulp.watch config.dest.root, [server.notify]

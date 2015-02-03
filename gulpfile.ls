require! \./config

require! <[ gulp gulp-util gulp-express gulp-livescript gulp-stylus gulp-jade ]>
require! <[ browserify watchify vinyl-source-stream vinyl-buffer ]>

bundler = watchify browserify config.src.browserify, watchify.args
  .on \update, bundle
  .on \time, (time) -> gulp-util.log "Browserify finished after #time ms"

function bundle
  bundler.bundle!
   .on \error, gulp-util.log.bind gulp-util, "Browserify error"
   .pipe vinyl-source-stream config.dest.browserify
   .pipe gulp.dest \.

gulp.task \browserify, bundle


#browserify-handler = (bundle) ->
#  bundle
#    .on \error, gulp-util.log.bind gulp-util, "Browserify error"
#    .pipe vinyl-source-stream config.dest.browserify
#    .pipe gulp.dest \.
#
#gulp.task \browserify, ->
#  browserify-handler browserify(config.src.browserify).bundle!
#
#gulp.task \watchify, ->
#  w = watchify browserify config.src.browserify, watchify.args
#  w.on \update, -> browserify-handler w.bundle!

gulp.task \views, ->
  gulp.src config.src.views
    .pipe gulp-jade!
    .pipe gulp.dest config.dest.views

gulp.task \component-views, ->
  gulp.src config.src.component-views
    .pipe gulp-jade!
    .pipe gulp.dest config.dest.component-views

gulp.task \styles, ->
  gulp.src config.src.styles
    .pipe gulp-stylus!
    .pipe gulp.dest config.dest.styles


gulp.task \build, <[ browserify views component-views styles ]>
gulp.task \default <[ build ]>

gulp.task \watch, <[ watchify ]>, ->
  gulp.watch config.src.views, <[ views ]>
  gulp.watch config.src.component-views, <[ component-views ]>
  gulp.watch config.src.styles, <[ styles ]>

gulp.task \server, <[ build watch ]>, ->
  start = ->
    gulp-util.log "Starting server"
    gulp-express.run do
      file: config.server
      port: config.livereload
  start!
  # TODO: copy watches from \watch task and have them trigger gulp-express.notify
  gulp.watch "#{config.server}/**/*", [start]

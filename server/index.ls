require! \../config
require! express

module.exports = app = express!

# Logging
app.use (req, res, next) ->
  time = (new Date).toTimeString!.split(' ')[0]
  console.log "[#time] #{req.method} #{req.path} from #{req.ip}"
  next!

# File serving
app.use express.static config.dest.root

# Start up server
app.listen config.port, ->
  console.log "Server listening on port #{config.port} as #{process.env.NODE_ENV}"

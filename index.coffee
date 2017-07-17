
path = require "path"

module.exports = (app, router) ->
	app.sbks.setView path.join __dirname, "./server/views"

	router.init @opts.screenName,
		routes: require "./server/routes/main"
		use:
			"/static": require "./server/routes/static"

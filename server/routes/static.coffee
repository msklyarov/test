express = require 'express'
path = require 'path'
serveStatic = require 'serve-static'

module.exports = router = express.Router()

if process.config.env isnt 'production'
	js  = require '../../../../build/bundles/js'
	css = require '../../../../build/bundles/css'

	coffeeFilePath = path.join __dirname, '../../app/coffee/app.coffee'
	lessFilePath = path.join __dirname, '../../app/styles/app.less'

	router.get '/dev.js', (req, res) ->
		res.set 'Content-Type', 'text/javascript'
		js.app(coffeeFilePath).bundle()
		.on 'error', (err) -> console.log err
		.pipe res

	router.get '/app.css', (req, res) ->
		res.set 'Content-Type', 'text/css'
		css.app(lessFilePath).bundle()
		.on 'error', (err) -> console.log err
		.pipe res

router.use serveStatic path.join __dirname, '../images'
router.use serveStatic path.join __dirname, '../lib'
router.use serveStatic path.join __dirname, '../dist'

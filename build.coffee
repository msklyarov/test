fs = require 'fs'
path = require 'path'
async = require 'async'
buildHelper = require '../../build/helper'

js = require '../../build/bundles/js'
css = require '../../build/bundles/css'

module.exports = (next) ->
	destDirPath = path.join __dirname, './server/dist'
	coffeeFilePath = path.join __dirname, 'app/coffee/app.coffee'
	lessFilePath = path.join __dirname, 'app/styles/app.less'

	buildHelper.prepareBuild destDirPath

	async.parallel [
		(next) ->
			buildHelper.store js.all(coffeeFilePath).bundle(), destDirPath, 'app.js', next
		(next) ->
			buildHelper.store js.shared.bundle(), destDirPath, 'shared.js', next
		(next) ->
			buildHelper.store css.app(lessFilePath).bundle(), destDirPath, 'app.css', next

	], next

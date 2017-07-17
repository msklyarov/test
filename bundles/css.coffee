fs      = require "fs"
path    = require "path"
less    = require "less"
stream  = require "stream"
postcss = require "postcss"

createLessBundle = (file, processors...) ->
	bundle: ->
		filePath = path.resolve path.join __dirname, file
		output = new stream.Readable
		output._read = (length) ->
			undefined

		fs.readFile filePath, encoding: "utf-8", (err, data) ->
			restoreCWD = process.chdir.bind process, process.cwd()
			riseStreamError = (err) ->
				output.emit "error", err
				restoreCWD()

			return riseStreamError err if err

			process.chdir path.dirname filePath

			transform = ({css}, success) ->
				postcss(processors)
					.process css
					.then ({css}) ->
						restoreCWD()
						output.push css
						output.push null
					, riseStreamError

			less
				.render data
				.then transform, riseStreamError

		output

# main CSS file
app = createLessBundle "../app/styles/app.less"

module.exports = {app}

fs          = require "fs"
path        = require "path"
assert      = require "assert"
browserify  = require "browserify"
incremental = require "browserify-incremental"

# shared thirdparty packages for dev
shared = browserify {}
shared.require sharedModules = ["react", "react-dom", "react-addons-css-transition-group"]

filePath = path.join __dirname, "../app/coffee/app.coffee"
# development file
app = incremental filePath, {extensions: [".coffee", ".js", ".jsx"]}
app.external sharedModules

# production file
all = browserify filePath, {fullPaths: no, extensions: [".coffee", ".js", ".jsx"]}

module.exports = {all, app, shared}

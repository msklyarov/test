React       = require "react"

Controls = require "./components/controls"

module.exports = Footer = React.createClass
	render: ->
		<div className="footer">
			<Controls {...@props} />
			<div className="socialbakers" />
		</div>

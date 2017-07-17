React    = require "react"

Settings = require "./components/settings"

module.exports = Header = React.createClass

	render: ->
		<div className="header">
			<div className="desigual" />
			<div className="headline">Community KPI</div>
			<div className="header__settings">
				<Settings {...@props} />
			</div>
		</div>

React    = require "react"

{format} = require "../helper"

module.exports = FbGeneral = React.createClass

	propTypes:
		value: React.PropTypes.number.isRequired

	render: ->
		switch
			when @props.value > 0
				change = "+ "
				colorClass = " positive"
			when @props.value < 0
				change = "- "
				colorClass = " negative"
			else
				change = "±"
				colorClass = ""
		<span className="metric-change#{colorClass}">{change}{format Math.abs @props.value}</span>

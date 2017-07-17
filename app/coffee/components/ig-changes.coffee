React       = require "react"

ChartGraph  = require "./chart-graph"
Change      = require "./change"
{format}    = require "../helper"

DEFAULT_GRAPH_GAP_IG = 224

module.exports = IgChanges = React.createClass

	propTypes:
		followersChange: React.PropTypes.number.isRequired
		timerange: React.PropTypes.string.isRequired
		interactionsValues: React.PropTypes.array.isRequired
		interactionsChange: React.PropTypes.number.isRequired

	render: ->
		arrow = no
		for one in @props.interactionsValues when one > 0
			arrow = yes
			break
		timerangeClass = if @props.timerange is "last day" and arrow then " icon-arrow" else ""
		timerangeType = if @props.timerange is "last day" then "\u00A0" else "( #{@props.timerange} )"

		<div className="network-changes">
			<div className="growth">
				<div className="metric-title">Desigual Follower Growth</div>
				<Change value={@props.followersChange} />
			</div>
			<div className="interactions">
				<div className="metric-title">Desigual Interactions per 1K Followers</div>
				<div className="metric-timerange">{timerangeType}</div>
				<span className="metric-value">{format @props.interactionsValues[@props.interactionsValues.length - 1]}</span>
				<Change value={@props.interactionsChange} />
				<div className="metric-evolution#{timerangeClass}">
					<ChartGraph data={@props.interactionsValues} gap={DEFAULT_GRAPH_GAP_IG / @props.interactionsValues.length} color="#694F36" />
				</div>
			</div>
		</div>

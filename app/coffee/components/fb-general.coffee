React       = require "react"
ReactCSSTransitionGroup = require "react-addons-css-transition-group"

ChartGraph  = require "./chart-graph"
Change      = require "./change"
{
	format
	humanize
}           = require "../helper"

DEFAULT_GRAPH_GAP_FB = 224

module.exports = FbGeneral = React.createClass

	propTypes:
		activePage: React.PropTypes.number.isRequired
		timerange: React.PropTypes.string.isRequired
		fansTotal: React.PropTypes.number.isRequired
		fansChange: React.PropTypes.number.isRequired
		reach: React.PropTypes.object.isRequired

	getInitialState: ->
		reachName: null

	componentWillUpdate: (nextProps) ->
		@setState reachName: nextProps.reach.name if @props.reach.name isnt nextProps.reach.name

	render: ->
		arrow = no
		for one in @props.reach.values when one > 0
			arrow = yes
			break
		timerangeClass = if @props.timerange is "last day" and arrow then " icon-arrow" else ""
		timerangeType = if @props.timerange is "last day" then " Page Reach " else " Page Reach ( #{@props.timerange} ) "

		<div className="network-general">
			<div className="network-title">Facebook</div>
			<div className="network-logo"><div className="sprite sprite-logo" /></div>
			<div className="network-stats">
				<div className="fans">
					<div className="metric-title">Desigual No. of Fans</div>
					<span className="metric-value">{format @props.fansTotal}</span>
					<Change value={@props.fansChange} />
				</div>
				<div className="reach">
				<ReactCSSTransitionGroup
					transitionName="opacity-top"
					transitionEnterTimeout={1000}
					transitionLeaveTimeout={500}>
						<div className="fb-global-reach-wrap" key="#{@state.reachName}">
							<div className="metric-title">
								<span className="metric-title">
									<span className="bold">{@props.reach.name}</span>
									 {timerangeType}
								</span>
								{for i in [0..3]
									activeClass = if i is @props.activePage then " active" else ""
									<span key={i} className="metric-active bold#{activeClass}">.</span>}
							</div>
							<span className="metric-value">{format @props.reach.values[@props.reach.values.length - 1]}</span>
							<Change value={@props.reach.change} />
							<div className="metric-graph">
								<div className="metric-evolution#{timerangeClass}">
									<ChartGraph data={@props.reach.values} gap={DEFAULT_GRAPH_GAP_FB / @props.reach.values.length} color="#3A63B9" />
								</div>
							</div>
						</div>
					</ReactCSSTransitionGroup>
				</div>
			</div>
		</div>

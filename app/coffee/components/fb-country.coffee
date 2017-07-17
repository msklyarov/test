React       = require "react"
ReactCSSTransitionGroup = require "react-addons-css-transition-group"

Map         = require "./map"
Change      = require "./change"
{format}    = require "../helper"

SMALLER_COUNTRY_NAMES = ["RUS", "ARE"]

module.exports = FbCountry = React.createClass

	keyId: 0

	propTypes:
		fansPercentage: React.PropTypes.number.isRequired
		fans: React.PropTypes.object

	render: ->
		smallClass = if @props.fans?.code in SMALLER_COUNTRY_NAMES then "-small" else ""

		<div className="network-country">
			<Map countryCode={@props.fans?.code or ""} />
			{if @props.fans
				<ReactCSSTransitionGroup
					transitionName="opacity"
					transitionEnterTimeout={1000}
					transitionLeaveTimeout={1000}>
					<div className="wrap" key="#{@keyId++}">
						<div className="distribution" key="d">
							<div className="rings">&nbsp;</div>
							<div className="metric-distribution">
								<div className="metric-value">{@props.fansPercentage.toFixed(0)}%</div>
								<div className="metric-title">of fan distribution</div>
							</div>
						</div>
						<div id="fb-stats" className="stats" key="s">
							<div className="flag"><div className="sprite sprite-#{@props.fans.code}" /></div>
							<div className="country-line" />
							<div className="country-name#{smallClass}">{@props.fans.name}</div>
							<div className="country-line" />
							<div className="fans">
								<div className="metric-title">No. of Fans</div>
								<span className="metric-value-bigger">{format @props.fans.total}</span>
								<Change value={@props.fans.change} />
							</div>
						</div>
					</div>
				</ReactCSSTransitionGroup>}
		</div>

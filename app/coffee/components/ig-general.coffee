React       = require "react"

{format}    = require "../helper"

module.exports = IgGeneral = React.createClass

	propTypes:
		followersTotal: React.PropTypes.number.isRequired

	render: ->
		<div className="network-general">
			<div className="network-title">Instagram</div>
			<div className="network-logo"><div className="sprite sprite-logo" /></div>
			<div className="network-stats">
				<div className="followers">
					<div className="metric-title">Desigual No. of Followers</div>
					<div className="metric-value">{format @props.followersTotal}</div>
				</div>
			</div>
		</div>

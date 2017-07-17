React       = require "react"

FbGeneral = require "./components/fb-general"
FbCountry = require "./components/fb-country"
IgGeneral = require "./components/ig-general"
IgChanges = require "./components/ig-changes"

module.exports = Content = React.createClass

	propTypes:
		fb: React.PropTypes.object.isRequired
		ig: React.PropTypes.object.isRequired
		dataLoaded: React.PropTypes.number

	render: ->
		interactionsValues = @props.ig?.interactions?.values or []
		countryTotal = @props.fb.byCountry?.total or 0

		<div className="content">
		{if @props.dataLoaded
			[
				<div className="facebook" key="f">
					<FbGeneral
						timerange={@props.timerange}
						fansTotal={@props.fb.total or 0}
						fansChange={@props.fb.change or 0}
						activePage={@props.activePage}
						reach={@props.fb.byPage} />
					<FbCountry
						fans={@props.fb.byCountry}
						fansPercentage={if @props.fb.total then countryTotal / @props.fb.total * 100 else 0} />
				</div>
			,
				<div className="instagram" key="i">
					<IgGeneral followersTotal={@props.ig.followers.total or 0} />
					<IgChanges
						timerange={@props.timerange}
						followersChange={@props.ig.followers.change or 0}
						interactionsValues={interactionsValues}
						interactionsChange={@props.ig.interactions.change or 0} />
				</div>
			]
		else
			<div className="user-interaction">
				{<div className="loader" /> unless @props.dataLoaded}
			</div>}
		</div>

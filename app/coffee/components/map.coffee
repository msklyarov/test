React = require "react"

MAP_HALF = 500

module.exports = Map = React.createClass

	setMap: ->
		{max, min} = @props
		mapEl = @refs.map
		mapEl.removeChild mapEl.firstChild if mapEl.firstChild
		mapEl.removeChild mapEl.firstChild if mapEl.firstChild

		fills =
			"#{@props.countryCode}": "#FFF"
			defaultFill: "#424445"

		map = new Datamap
			element: mapEl
			scope: "world"
			geographyConfig:
				highlightOnHover: false
				borderWidth: 0.5
				borderColor: "#2f3133"
				popupTemplate: ->
					undefined
			fills: fills
			data: "#{@props.countryCode}": fillKey: "#{@props.countryCode}"
			setProjection: (element) ->
				projection = d3.geo.mercator()
					.center [-8, 43]
					.rotate [-20, 0]
					.scale 180
				path = d3.geo.path()
					.projection projection
				path: path
				projection: projection

		activeCountryEl = document.getElementsByClassName(@props.countryCode)?[0]
		if activeCountryEl
			distributionEl = document.getElementsByClassName("distribution")[0]
			mapBounds = document.getElementById("map").getBoundingClientRect()
			rootStyle = document.getElementById("root").style

			shiftTransform = parseFloat rootStyle.transform?.split("(")?[1]?.split(")")?[0] or 1
			activeCountryBounds = activeCountryEl.getBoundingClientRect()

			# FAKECODED BOUNDS
			if @props.countryCode is "USA" # using Mexico as base point to get to USA borders because Alaska is too far away lol..
				activeCountryBounds = document.getElementsByClassName("MEX")?[0].getBoundingClientRect()
				newCountryBounds =
					top: activeCountryBounds.top - activeCountryBounds.height / 4
					bottom: activeCountryBounds.bottom - activeCountryBounds.height / 4
					height: activeCountryBounds.height
					width: activeCountryBounds.width * 1.7
					left: activeCountryBounds.left
					right: activeCountryBounds.left + activeCountryBounds.width * 1.7
				activeCountryBounds = newCountryBounds
			# FAKECODED BOUNDS

			if (activeCountryBounds.left / shiftTransform) < MAP_HALF
				document.getElementById("fb-stats").style.left = "650px"
			else
				document.getElementById("fb-stats").style.left = "50px"

			diameter = Math.max(activeCountryBounds.width / shiftTransform, activeCountryBounds.height / shiftTransform)
			moveY = activeCountryBounds.height / shiftTransform
			moveX = activeCountryBounds.width / shiftTransform

			distributionEl.firstChild.style.width = "#{diameter}px"
			distributionEl.firstChild.style.height = "#{diameter}px"
			distributionEl.style.top = "#{activeCountryBounds.top / shiftTransform - mapBounds.top / shiftTransform + moveY - diameter}px"
			distributionEl.style.left = "#{activeCountryBounds.left / shiftTransform - mapBounds.left / shiftTransform + moveX - diameter}px"

	componentDidMount: ->
		@setMap()

	componentDidUpdate: ->
		@setMap()

	render: ->
		<div id="map" ref="map" />

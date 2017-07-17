React       = require "react"

s = 1000

module.exports = Controls = React.createClass

	timer: null
	SLIDE_TIME: 15 * s

	getInitialState: ->
		everyNth: 0
		nth: 2

	circularChange: (arr, actualIndex, change) ->
		return 0 unless arr?.length or isNaN actualIndex or isNaN change
		return actualIndex unless change
		newIndex = actualIndex + change

		if newIndex >= arr.length
			return 0
		else if newIndex < 0
			return arr.length - 1
		newIndex

	prev: ->
		if @state.everyNth - 1 <= 0
			@setState everyNth: @state.nth
			page = -1
		else
			@setState everyNth: @state.everyNth - 1
			page = 0

		@props.updateState ["activePage", "activeCountry"], [@circularChange(@props.byPage, @props.activePage, page), @circularChange(@props.selectedLabel, @props.activeCountry, -1)]

	next: ->
		if @state.everyNth + 1 >= @state.nth
			@setState everyNth: 0
			page = 1
		else
			@setState everyNth: @state.everyNth + 1
			page = 0
		@props.updateState ["activePage", "activeCountry"], [@circularChange(@props.byPage, @props.activePage, page), @circularChange(@props.selectedLabel, @props.activeCountry, 1)]

	play: ->
		clearInterval @timer
		@timer = setInterval @next, @SLIDE_TIME
		@props.updateState ["paused"], [no]

	pause: ->
		clearInterval @timer
		@timer = null
		@props.updateState ["paused"], [yes]

	componentWillUnmount: ->
		clearInterval @timer
		@timer = null

	componentWillUpdate: (newProps) ->
		if not @props.paused and newProps.paused then return @pause()
		if @props.paused and not newProps.paused then @play()

	render: ->
		<div className="controls">
			<div className="controls__button icon-controls-backward" onClick={@prev}></div>
			{if @props.paused
				<div className="controls__button icon-controls-play" onClick={@play}></div>
			else
				<div className="controls__button icon-controls-pause" onClick={@pause}></div>
			}
			<div className="controls__button icon-controls-forward" onClick={@next}></div>
		</div>

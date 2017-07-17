React = require "react"

module.exports = ColumnChart = React.createClass

	propTypes: ->
		data: React.PropTypes.arrayOf(React.PropTypes.number).isRequired

	getInitialState: ->
		maxValue: 0

	getDefaultProps: ->
		width: 315
		height: 80
		gap: 32
		color: "#DDDDDD"
		negativeColor: "#D33E41"
		anim: yes

	setAbsoluteMax: (data = @props.data) ->
		@setState maxValue: Math.max.apply null, data.map(Math.abs)

	componentWillMount: ->
		@setAbsoluteMax()

	componentWillReceiveProps: (nextProps) ->
		@setAbsoluteMax(nextProps.data)

	renderDataValue: (value, index) ->
		color = @props.color
		curHeight = if @state.maxValue then (@props.height / @state.maxValue * value ) else 0
		if curHeight < 0
			curHeight = Math.abs(curHeight)
			color = @props.negativeColor
		gap = @props.gap
		columnWidth = Math.max(0, (@props.width - gap * (@props.data.length - 1)) / @props.data.length) #cannot be negative

		classname = "column-chart-col column-chart-col-#{index}"
		classname += " no-anim" if not @props.anim

		<rect
			key={"column-chart-col-" + index}
			className={classname}
			x={(columnWidth + gap) * index}
			y={0}
			width={columnWidth}
			height={curHeight}
			fill={color}/>

	render: ->
		<svg xmlns="http://www.w3.org/2000/svg" width={@props.width} height={@props.height}>
			<g transform={"translate(0, " + @props.height + ")"}>
				<g className="graph-columns" transform="scale(1, -1)">
					{@props.data.map(@renderDataValue)}
				</g>
			</g>
		</svg>

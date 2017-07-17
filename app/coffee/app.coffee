React         = require "react"
ReactDOM      = require "react-dom"
async         = require "async"
_             = require "lodash"
moment        = require "moment"

ScreenScale   = require "../../../../components/screen-scale/screen-scale"
request       = require "../../../../request"

Header        = require "./header"
Content       = require "./content"
Footer        = require "./footer"

transform     = require "./transform"

backendUrl = process.env.BACKEND_URL or ""
DATE_LENGTH = 10

App = React.createClass

	getInitialState: ->
		hasStorage = 'localStorage' of window

		if hasStorage
			timerange = localStorage.getItem "timerange"
			timeFrom = localStorage.getItem "timeFrom"
			timeTo = localStorage.getItem "timeTo"
			# better check if needed
			if timeFrom?.length isnt DATE_LENGTH or timeTo?.length isnt DATE_LENGTH
				timeFrom = null
				localStorage.setItem "timeFrom", null
				timeTo = null
				localStorage.setItem "timeTo", null

			try
				label = JSON.parse localStorage.getItem "label"
			catch e
				localStorage.removeItem "label"

		timerange = "last 7 days" unless timerange in ["last day", "last 7 days", "last 28 days"]

		timeFrom = null if not(timeFrom) or timeFrom is "null"
		timeTo = null if not(timeTo) or timeTo is "null"
		label = [] unless label?.length

		hasStorage: hasStorage
		settings:
			timerange: timerange
			timeFrom: timeFrom
			timeTo: timeTo
			label: label
		settingsOptions:
			timeranges: []
			labels: []
		settingsLoaded: no
		dataLoaded: 0
		loading: no
		activeCountry: 0
		activePage: 0
		paused: no
		data:
			fb:
				byCountry: {}
				byPage: []
			ig: {}

	isDayOld: ->
		d1 = new Date()
		return yes if d1.getDate() isnt @state.dataLoaded
		no

	_onSettingsSave: (newSettings) ->
		byCountry = @state.data.fb.byCountry
		labels = [].concat newSettings.label
		labels.sort (a, b) ->
			return 1 if byCountry[a].name > byCountry[b].name
			return -1 if byCountry[a].name < byCountry[b].name
			return 0
		if @state.hasStorage
			localStorage.setItem "timerange", newSettings.timerange
			localStorage.setItem "timeFrom", newSettings.timeFrom
			localStorage.setItem "timeTo", newSettings.timeTo
			localStorage.setItem "label", JSON.stringify labels
		@setState
			settings: newSettings
			paused: no

	updateState: (keys, values) ->
		state = {}
		state[key] = values[i] for key, i in keys
		@setState state

	resize: ->
		# debounced scaling of the whole screen with keeping its original aspect ratio
		window.addEventListener 'resize', ScreenScale.scaleViewport "#root"
		window.addEventListener 'load', ScreenScale.scaleViewport "#root"
		window.addEventListener 'orientationchange', ScreenScale.scaleViewport "#root"

	getSettingsOptions: ->
		async.parallel [
			(next) -> request.post "#{backendUrl}/api/desigual-kpi/0/get-timeranges", next
		], (e, r) =>
			return unless @isMounted
			if e
				console.log "ERR:#{e}"
				@setState
					error: e
					settingsLoaded: no
				return

			@setState
				settingsOptions:
					timeranges: r[0].data
					labels: []
				settingsLoaded: yes
				dataLoaded: 0

	getData: ->
		wasPaused = @state.paused
		@setState
			loading: yes
			paused: yes
		params =
			timerange: @state.settings.timerange
		if @state.settings.timeFrom
			params.timeFrom = @state.settings.timeFrom
			params.timeTo = @state.settings.timeTo
		request.post "#{backendUrl}/api/desigual-kpi/0/get-data", params, (e, r) =>
			return unless @isMounted()
			if e
				console.log "ERR:#{JSON.stringify e}" if typeof e is "object"
				console.log "ERR:#{e}" if typeof e isnt "object"
				return @setState
					error: e
					loading: no

			if r?.data?.field in ["/timeFrom", "/timeTo"]
				if @state.hasStorage
					localStorage.setItem "timerange", "last 7 days"
					localStorage.setItem "timeFrom", null
					localStorage.setItem "timeTo", null
				newSettings = Object.assign {}, @state.settings
				newSettings.timerange = "last 7 days"
				newSettings.timeFrom = null
				newSettings.timeTo = null
				return @setState
					error: r.data
					loading: no
					settings: newSettings

			countries = transform.countries r.data.facebook.local_fans
			fb = transform.facebook r.data.facebook, @state.settingsOptions.labels
			ig = transform.instagram r.data.instagram
			date = new Date()
			@setState
				loading: no
				paused: wasPaused
				dataLoaded: date.getDate()
				data:
					fb: fb
					ig: ig
				settingsOptions:
					labels: countries
					timeranges: @state.settingsOptions.timeranges

	componentDidMount: ->
		@resize()
		@getSettingsOptions()
		window["jaksemas"] = => @state

	componentWillUpdate: (nextProps, nextState) ->
		return unless @state?.settings and nextState?.settings
		if @state?.settings?.timerange isnt nextState.settings?.timerange or
		@state?.settings?.timeFrom isnt nextState.settings?.timeFrom or
		@state?.settings?.timeTo isnt nextState.settings?.timeTo
			@setState dataLoaded: 0

	componentDidUpdate: ->
		@getData() if (not @state.dataLoaded or @isDayOld()) and @state.settingsLoaded and not @state.loading

	render: ->
		stateFb = @state.data.fb
		fb =
			total: stateFb.total
			change: stateFb.change
			byCountry: stateFb.byCountry[@state.settings.label[@state.activeCountry]]
			byPage: stateFb.byPage[@state.activePage]

		<div className="screen">
			<Header
				stateTimerange={@state.settings.timerange}
				stateTimeFrom={@state.settings.timeFrom}
				stateTimeTo={@state.settings.timeTo}
				timeranges={@state.settingsOptions.timeranges}
				labels={@state.settingsOptions.labels}
				stateLabel={@state.settings.label}
				onSettingsSave={@_onSettingsSave}
				updateState={@updateState}
				loading={@state.loading} />
			<Content
				activePage={@state.activePage}
				activeCountry={@state.activeCountry}
				timerange={@state.settings.timerange}
				fb={fb}
				ig={@state.data.ig}
				dataLoaded={@state.dataLoaded} />
			<Footer
				updateState={@updateState}
				activePage={@state.activePage}
				activeCountry={@state.activeCountry}
				selectedLabel={@state.settings.label}
				byCountry={@state.data.fb.byCountry}
				byPage={@state.data.fb.byPage}
				paused={@state.paused} />
		</div>

ReactDOM.render <App />, document.getElementById "root"

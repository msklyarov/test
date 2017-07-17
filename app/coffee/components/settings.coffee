React = require 'react'
moment = require 'moment'
DayPicker = require 'react-day-picker'
{DateUtils, LocaleUtils} = require 'react-day-picker'
_ = require 'lodash'

module.exports = Settings = React.createClass

	propTypes:
		stateTimerange: React.PropTypes.string
		stateTimeFrom: React.PropTypes.string
		stateTimeTo: React.PropTypes.string
		timeranges: React.PropTypes.array
		labels: React.PropTypes.array
		stateLabel: React.PropTypes.array
		onSettingsSave: React.PropTypes.func
		loading: React.PropTypes.bool.isRequired

	getInitialState: ->
		timerangeSelected = @props.stateTimerange
		labelSelected = @props.stateLabel
		timeFromSelected = @_getDateFromString @props.stateTimeFrom
		timeToSelected = @_getDateFromString @props.stateTimeTo
		valid: yes
		label: labelSelected
		origLabel: labelSelected
		timerange: timerangeSelected
		origTimerange: timerangeSelected
		timeFrom: timeFromSelected
		origTimeFrom: timeFromSelected
		timeTo: timeToSelected
		origTimeTo: timeToSelected
		settingsOpen: no
		dropdownOpen: no
		customTimerangeOpen: no
		customTimerange: {from: timeFromSelected, to: timeToSelected}
		origCustomTimerange: {from: timeFromSelected, to: timeToSelected}
		changedCustomTimerange: {from: timeFromSelected, to: timeToSelected}
		customTimerangeValid: no
		initialMonth: @_getInitialMonth @_getDateFromString @props.stateTimeFrom

	shouldComponentUpdate: (nextProps, nextState) ->
		not _.isEqual @state, nextState

	_getDateFromString: (string) ->
		return null unless string
		a = new Date string.substring(0, 4), string.substring(5, 7) - 1, string.substring(8, 10)
		if a is "Invalid Date" then null
		a

	_onLabelChange: (labelId) ->
		newLabelSelected = _.extend [], @state.label
		if _.indexOf(newLabelSelected, labelId) is -1
			newLabelSelected.push labelId
		else
			_.pull newLabelSelected, labelId

		@setState label: newLabelSelected, ->
			@_validateSettings()

	_onTimerangeClick: (item) ->
		@setState
			timerange: item
			dropdownOpen: no

	_onCustomTimerangeClick: (item) ->
		@setState customTimerangeOpen: yes

	_handleCustomTimerangeReset: (e) ->
		e.preventDefault()
		@setState
			customTimerange:
				from: null
				to: null
			timeFrom: null
			timeTo: null
		, ->
			@_validateCustomTimerange()

	_handleCustomTimerangeClick: (e, day) ->
		date = new Date()
		date.setDate(date.getDate() + 1)
		date.setHours 0, 0, 0, 0
		if day < date
			range = DateUtils.addDayToRange day, @state.customTimerange
			@setState
				customTimerange: range
			, ->
				@_validateCustomTimerange()

	_validateSettings: ->
		@refs.settingsSaveBtn.classList.add 'settings__submit--disabled'
		labelValid = no
		for v in @state.label when v
			labelValid = yes
			break
		valid = labelValid
		@refs.settingsSaveBtn.classList.remove 'settings__submit--disabled' if valid

		@setState valid: valid

	_onSettingsSave: ->
		return unless @state.valid
		timeFrom = if @state.timeFrom then moment(@state.timeFrom).format('YYYY-MM-DD') else null
		timeTo = if @state.timeTo then moment(@state.timeTo).format('YYYY-MM-DD') else null

		updateOrigState =
			origLabel: _.extend [], @state.label
			origTimerange: @state.timerange
			origTimeFrom: timeFrom
			origTimeTo: timeTo
			customTimerange: @state.customTimerange
			settingsOpen: no
			dropdownOpen: no
		@setState updateOrigState

		@props.onSettingsSave
			label: @state.label
			timerange: @state.timerange
			timeFrom: timeFrom
			timeTo: timeTo
			customTimerange: @state.changedCustomTimerange

	_onCustomTimerangeSave: ->
		return unless @state.customTimerangeValid
		@setState
			timeFrom: moment(@state.customTimerange.from).format('YYYY-MM-DD')
			timeTo: moment(@state.customTimerange.to).format('YYYY-MM-DD')
			changedCustomTimerange:
				from: @state.customTimerange.from
				to: @state.customTimerange.to
			dropdownOpen: no
			customTimerangeOpen: no

	_validateCustomTimerange: ->
		valid = no
		@refs.customTimerangeSaveBtn.classList.add 'settings__submit--disabled'
		if @state.customTimerange.from and @state.customTimerange.to
			valid = moment(@state.customTimerange.to).diff(moment(@state.customTimerange.from), 'days') < 30
			@refs.customTimerangeSaveBtn.classList.remove 'settings__submit--disabled' if valid

		@setState customTimerangeValid: valid

	_getCurrentMonth: ->
		new Date()

	_getLocaleUtils: ->
		weekdaysLong =
			en: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
		weekdaysShort =
			en: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
		months =
			en: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
		firstDay =
			en: 1
		LocaleUtils.getFirstDayOfWeek = (locale = 'en') ->
			firstDay[locale]
		LocaleUtils.formatWeekdayShort = (i, locale = 'en') ->
			weekdaysShort[locale][i]
		LocaleUtils.formatMonthTitle = (d, locale = 'en') ->
			months[locale][d.getMonth()] + ', ' + d.getFullYear()
		LocaleUtils.formatWeekdayLong = (i, locale = 'en') ->
			weekdaysLong[locale][i]
		LocaleUtils

	_toggleSettings: ->
		return if @props.loading
		if @state.settingsOpen
			@props.updateState ["paused"], [no]
			@setState
				valid: yes
				label: @state.origLabel
				timerange: @state.origTimerange
				timeFrom: @state.origTimeFrom
				timeTo: @state.origTimeTo
				customTimerange: @state.origCustomTimerange
				settingsOpen: no
				dropdownOpen: no
			, ->
				@_validateSettings()
		else
			@props.updateState ["paused"], [yes]
			@setState
				settingsOpen: yes
				dropdownOpen: no

	_formatTimerangeName: (timerange, timeFrom) ->
		"#{timerange}" + if timeFrom then " + Custom" else ""

	_onDropdownLabelClick: (type) ->
		if @state.dropdownOpen is type
			newState =
				dropdownOpen: no
			if @state.dropdownOpen is "customTimerange"
				newState.customTimerange =
					from: @state.changedCustomTimerange.from
					to: @state.changedCustomTimerange.to
			@setState newState
		else
			@setState dropdownOpen: type

	_getTimerangeElem: (item, i) ->
		<div key={item} className="settings__dropdown__items__item">
			<div
				className="settings__dropdown__items__item__label"
				onClick={@_onTimerangeClick.bind @, item}>
				{item}
			</div>
		</div>

	_getCustomTimerangeModifiers: ->
		selected: (day) =>
			date = new Date()
			date.setDate(date.getDate() + 1)
			date.setHours 0, 0, 0, 0
			DateUtils.isDayInRange(day, @state.customTimerange) and (day < date)

		disabled: (day) ->
			date = new Date()
			date.setDate(date.getDate() + 1)
			date.setHours 0, 0, 0, 0
			day > date

	_getSelectedDays: (from, to) ->
		if @state.timerange is 'custom'
			# preselect provided timerange
			(day) -> DateUtils.isDayInRange(day, {from, to})
		null

	_getInitialMonth: (from) ->
		if from?
			date = moment(from).toDate()
		else
			date = new Date()
			date.setMonth(date.getMonth() - 1)
		date

	_handleMonthChange: (month) ->
		@setState
			initialMonth: month

	_getCustomTimerangeElem: ->
		from = moment(@state.customTimerange.from).toDate()
		to = moment(@state.customTimerange.to).toDate()
		settingsOpenClass = if @state.customTimerangeOpen then 'settings__dropdown__items__item__timerange--open' else ''
		<div key="custom" className="settings__dropdown__items__item__timerange #{settingsOpenClass}">
			<DayPicker
				ref='daypicker'
				numberOfMonths=2
				initialMonth={@state.initialMonth}
				toMonth={@_getCurrentMonth()}
				locale='en'
				localeUtils={@_getLocaleUtils()}
				modifiers={@_getCustomTimerangeModifiers()}
				onDayClick={@_handleCustomTimerangeClick}
				selectedDays={@_getSelectedDays from, to}
				onMonthChange={@_handleMonthChange}
			/>
			{
				if @state.customTimerange?
					[
						<div className="daypicker__selected" key='datepicker'>
							{
								if not @state.customTimerange.from and not @state.customTimerange.to
									<span>Please select the first day.</span>
								else if @state.customTimerange.from and not @state.customTimerange.to
									<span>Please select the last day.</span>
								else if @state.customTimerange.from and @state.customTimerange.to
									<span>
										You chose from {moment(from).format('YYYY-MM-DD')} to {moment(to).format('YYYY-MM-DD') }.
										<a href="#" onClick={@_handleCustomTimerangeReset}>Reset</a>
									</span>
							}
						</div>
						<a href="#" key="setButton" onClick={@_onCustomTimerangeSave} ref="customTimerangeSaveBtn" className="settings__submit settings__submit--timerange">Set timerange</a>
					]
			}
		</div>


	_getLabelElem: (item, i) ->
		checked = if item.code in @state.label then yes else no

		<div key={item.code} className="settings__dropdown__items__item">
			<div className="settings__dropdown__items__item__label">
				<div className="settings__dropdown__items__item__row">
					<input
						type="checkbox"
						className="settings__checkbox"
						id="settings__dropdown__items__item--#{item.code}"
						value={item.code}
						checked={checked}
						onChange={@_onLabelChange.bind @, item.code}
					/>
					<label
						className="settings__label"
						htmlFor="settings__dropdown__items__item--#{item.code}"
					>
						{item.name}
					</label>
				</div>
			</div>
		</div>

	_getDropdown: (type, selectedValue, availableValues, displayLabel, itemsDisplayFunction) ->
		switch
			when type is 'timerange'
				iconType =  'calendar'
				classType = ""
				idType = ""
			when type is 'customTimerange'
				iconType =  'calendar'
				classType = ""
				idType = ""
			when type is 'label'
				iconType = 'flag'
				classType = "scrollbar force-overflow"
				idType = "style-2"
		dropdownOpenClass = if @state.dropdownOpen is type then 'settings__dropdown--open' else 'settings__dropdown--closed'
		customTimerange = if type is "customTimerange" then "customTimerange" else ""
		<div className="settings__options__item">
			<div className="settings__options__item__label">
				<span className="settings__icon icon-#{iconType}"></span>
				{displayLabel}
			</div>
			<div className="settings__options__item__value">
				<div className="settings__dropdown #{dropdownOpenClass}">
					<div
						className="settings__dropdown__selected"
						onClick={@_onDropdownLabelClick.bind @, type}>
						{selectedValue}
					</div>
					<div id={idType} className="#{classType} settings__dropdown__items #{customTimerange} settings_dropdown__#{type}s">
						{availableValues.map (item, i) -> itemsDisplayFunction item, i}
					</div>
				</div>
			</div>
		</div>

	render: ->
		settingsOpenClass = if @state.settingsOpen then 'settings--open' else 'settings--closed'
		disabled = @props.loading
		countriesCountLabel = if @state.label.length then "#{@state.label.length}/#{@props.labels.length}" else 'Choose…'
		<div className="settings #{settingsOpenClass}" disabled={disabled}>
			<div
				className="settings__current"
				onClick={@_toggleSettings}>
				<strong className="settings__current__text">{@_formatTimerangeName @state.timerange, @state.timeFrom}</strong>
			</div>
			<div className="settings__options">
				{@_getDropdown 'timerange', @state.timerange, @props.timeranges, 'Select timeframe', @_getTimerangeElem}
				{@_getDropdown 'customTimerange', "Custom", ["Custom"], 'Select custom timeframe', @_getCustomTimerangeElem}
				{@_getDropdown 'label', countriesCountLabel, @props.labels, 'Select country', @_getLabelElem}
				<button onClick={@_onSettingsSave} ref="settingsSaveBtn" className="settings__submit">Save preset</button>
			</div>
		</div>

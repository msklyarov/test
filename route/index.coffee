{
MissingParameterError
InvalidParameterError
} = require '../../../errors'


module.exports = (
	router
	desigualKpiConfigMain
	desigualKpiServiceKpi
	validatorDateTime
) ->
	router.init @opts.screenName

	###
	Get kpi data
	input:
		timerange: string (last day/last 7 days/last 28 days)
		timeFrom: string (YYYY-MM-DD)
		timeTo: string (YYYY-MM-DD)
	###
	router.post "/0/get-data", ({data}, next) ->
		return next new MissingParameterError field: field unless data.timerange
		unless data.timerange in desigualKpiConfigMain.timeranges
			return next new InvalidParameterError name: 'timerange', val: data.timerange

		# Validate timerange
		if data.timeFrom? and data.timeTo?
			err = validatorDateTime.isTimerangeValid data.timeFrom, data.timeTo
			return next err if err

		desigualKpiServiceKpi.getData data.timerange, data.timeFrom, data.timeTo, next

	###
	###
	router.post "/0/get-timeranges", desigualKpiServiceKpi.getTimeranges

	###
	###
	router.post "/0/get-countries", desigualKpiServiceKpi.getCountries

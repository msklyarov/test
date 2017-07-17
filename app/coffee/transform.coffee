countriesi18n = require 'i18n-iso-countries'
ALLOWED_COUNTRIES =
	[
		"ITA",
		"ESP",
		"FRA",
		"PRT",
		"DEU",
		"MEX",
		"BRA",
		"BEL",
		"USA",
		"SRB",
		"AUT",
		"COL",
		"ROU",
		"GBR",
		"SGP",
		"POL",
		"SVN",
		"JPN",
		"NLD",
		"HUN",
		"CZE",
		"ISR",
		"HRV",
		"CHE",
		"BGR",
		"CRI",
		"ARG",
		"ARM",
		"ARE",
		"HKG",
		"CAN",
		"EST",
		"SWE",
		"GRC",
		"CHL",
		"PER",
		"EGY",
		"DNK",
		"SVK",
		"FIN",
		"MLT",
		"IND",
		"LUX",
		"IRN",
		"RUS"
	]

mockCountry =
	ESP:
		name: "Spain"
		code: "ESP"
		total: 2500000
		change: -200000
	GBR:
		name: "Great Britain"
		code: "GBR"
		total: 4000000
		change: 125000
	FRA:
		name: "France"
		code: "FRA"
		total: 1000000
		change: 100000
	ITA:
		name: "Italia"
		code: "ITA"
		total: 1000000
		change: 100000
mockPages = [
	name: "desigual"
	values: [150000000, 160000000, 165000000, 170000000, 175000000, 175000000, 180000000]
	change: 5000000
,
	name: "desigual2"
	values: [100000000, 105000000, 110000000, 111000000, 112000000, 120000000, 123000000]
	change: 3000000
,
	name: "desigual4"
	values: [100000000, 105000000, 110000000, 111000000, 112000000, 120000000, 123000000]
	change: 2000
,
	name: "desigual6"
	values: [100000000, 105000000, 110000000, 111000000, 112000000, 120000000, 123000000]
	change: -50000
]

transformLocalFansToCountry = (localFans) ->
	countries = {}
	for key, val of localFans
		countries[key] =
			name: countriesi18n.getName "#{key}", "en"
			code: key
			total: localFans[key].total or 0
			change: localFans[key].change or 0
			percent: localFans[key].percent or 0
	countries

transformReachToPage = (reach) ->
	pages = []
	for key, val of reach
		values = val.evolution
		values[i] = 0 for value, i in values when not value

		pages.push
			name: key
			values: values
			change: val.change or 0
			total: val.total or 0
	pages.sort (a, b) -> a.name >= b.name

module.exports = transform =

	countries: (data) ->
		countries = []
		for key, val of data when key in ALLOWED_COUNTRIES
			countries.push
				lang: key
				code: key
				name: countriesi18n.getName "#{key}", "en"
		countries.sort (a, b) ->
			return 1 if a.name > b.name
			return -1 if a.name < b.name
			return 0

	facebook: (data) ->
		total: data.fans or 0
		change: data.fans_change or 0
		byCountry: transformLocalFansToCountry data.local_fans
		byPage: transformReachToPage data.reach

	instagram: (data) ->
		inter = data.interactions_evolution
		inter[i] = 0 for value, i in inter when not value

		followers:
			total: data.fans or 0
			change: data.fans_change or 0
		interactions:
			values: inter
			change: data.interactions_change or 0
		###
				data:
					fb:
						total: 12250000
						change: 15250
						byCountry: [
							name: "Germany"
							code: "DEU"
							total: 2500000
							change: -200000
						,
							name: "Great Britain"
							code: "GBR"
							total: 4000000
							change: 125000
						,
							name: "Czech Republic"
							code: "CZE"
							total: 1000000
							change: 100000
						]
						byPage:[
							name: "desigual"
							values: [150000000, 160000000, 165000000, 170000000, 175000000, 175000000, 180000000]
							change: 5000000
						,
							name: "desigual2"
							values: [100000000, 105000000, 110000000, 111000000, 112000000, 120000000, 123000000]
							change: 3000000
						,
							name: "desigual4"
							values: [100000000, 105000000, 110000000, 111000000, 112000000, 120000000, 123000000]
							change: 1000000
						]
					ig:
						followers:
							total: 440000
							change: 145
						interactions:
							values: [35000, 36000, 37000, 40000, 12000, 43000, 45000]
							change: 2000
		###

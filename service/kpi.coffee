countries = require 'i18n-iso-countries'
moment  = require 'moment'
async   = require 'async'
_ = require 'lodash'

metrics =
	facebook:
		'fan_count_lifetime_by_day': 'fb-benchmark'
		'fan_change_by_day': 'fb-profile'
		'fan_count_lifetime_by_country_by_day': 'fb-insights'
		'page_impressions_unique_by_day': 'fb-insights'
	instagram:
		'followedby_count_lifetime_by_day': 'ig-profile'
		'followedby_change_by_day': 'ig-profile'
		'profile_interaction_count_per_1000_followedby_by_day': 'ig-profile'



module.exports = (
	heraRemote
	desigualKpiConfigMain
) ->

	getData = (timerange, timeFrom, timeTo, next) ->

		out =
			facebook:
				fans: 0
				fans_change: 0
				local_fans: {}
				reach: {}

			instagram:
				fans: 0
				fans_change: 0
				interactions: 0
				interactions_change: 0
				interactions_evolution: []

		for name, val of desigualKpiConfigMain.ids.facebook
			out.facebook.reach[name] =
				total: 0
				change: 0
				evolution: []

		async.parallel [

			# calculate facebook fans
			(next) ->
				to = new Date()
				from = new Date()
				to.setDate to.getDate() - 1

				# TODO: missing data for last ~3 days
				to.setDate to.getDate() - 3
				from.setDate from.getDate() - 3

				switch timerange
					when "last day"
						from.setDate from.getDate() - 1 - 1
					when "last 7 days"
						from.setDate from.getDate() - 7 - 1
					when "last 28 days"
						from.setDate from.getDate() - 28 - 1

				params =
					timeFrom: moment(from).format 'YYYY-MM-DD'
					timeTo: moment(to).format 'YYYY-MM-DD'
					metrics: [
						'fan_count_lifetime_by_day'
					]
					items: [
						id: '24477009638'
						type: 'fb-profile'
					,
						id: '1588524668099814'
						type: 'fb-profile'
					,
						id: '1497945420520561'
						type: 'fb-profile'
					,
						id: '1627700970844024'
						type: 'fb-profile'
					]

				heraRemote.post "metricsApi", params, (err, res) ->
					return next err if err

					for name, metric of res.map
						for item in res.items
							{values} = item

							# total fans and fans change should be count only from the main profile
							if item.id is '24477009638' and metric is 'fan_count_lifetime_by_day'
								out.facebook.fans += values[values.length - 1][name] or 0

								if timerange is 'last day'
									out.facebook.fans_change += values[values.length - 1][name] - values[0][name]
								else if timerange is 'last 7 days'
									out.facebook.fans_change += values[values.length - 1][name] - values[0][name]
								else
									out.facebook.fans_change += values[values.length - 1][name] - values[0][name]

					next()

			# calculate facebook per country
			(next) ->
				to = new Date()
				from = new Date()
				to.setDate to.getDate() - 1

				# TODO: missing data for last ~3 days
				to.setDate to.getDate() - 3
				from.setDate from.getDate() - 3

				switch timerange
					when "last day"
						from.setDate from.getDate() - 1 - 1
					when "last 7 days"
						from.setDate from.getDate() - 7 - 1
					when "last 28 days"
						from.setDate from.getDate() - 28 - 1

				to = new Date timeTo if timeTo
				if timeFrom
					from = new Date timeFrom
					from.setDate from.getDate() - 1

				params =
					timeFrom: moment(from).format 'YYYY-MM-DD'
					timeTo: moment(to).format 'YYYY-MM-DD'
					type: 'fb-profile'
					metrics: [
						'fan_count_lifetime_by_country_by_day'
					]
					aggregate: 'fan_count_lifetime_by_country_by_day': ['simple.last_non_null']
					items: [
						id: '24477009638'
					,
						id: '1588524668099814'
					,
						id: '1497945420520561'
					,
						id: '1627700970844024'
					]

				heraRemote.post "metricsApi", params, (err, res) ->
					return next err if err

					for name, metric of res.map
						for item in res.items
							{values, aggregate} = item

							if metric is 'fan_count_lifetime_by_country_by_day'
								for country, aggregations of aggregate[name].simple
									value = aggregations.last_non_null
									countryAlpha3 = countries.alpha2ToAlpha3 country
									out.facebook.local_fans[countryAlpha3] ?=
										total: 0
										change: 0
										percent: 0

									out.facebook.local_fans[countryAlpha3].total += value or 0

									if timerange is 'last day'
										out.facebook.local_fans[countryAlpha3].change += value - values[0][name][country]
									else if timerange is 'last 7 days'
										out.facebook.local_fans[countryAlpha3].change += value - values[0][name][country]
									else
										out.facebook.local_fans[countryAlpha3].change += value - values[0][name][country]

					for country, values of out.facebook.local_fans
						out.facebook.local_fans[country].percent = out.facebook.local_fans[country].total / out.facebook.fans

					next()

			# calculate facebook reach
			(next) ->
				to = new Date()
				from = new Date()
				to.setDate to.getDate() - 1

				# TODO: missing data for last ~3 days
				to.setDate to.getDate() - 3
				from.setDate from.getDate() - 3

				switch timerange
					when "last day"
						metric = "page_impressions_unique_by_day"
						from.setDate from.getDate() - 1 - 6
					when "last 7 days"
						metric = "page_impressions_unique_7days_by_day"
						from.setDate from.getDate() - 7 - 7
					when "last 28 days"
						metric = "page_impressions_unique_28days_by_day"
						from.setDate from.getDate() - 28 - 28

				params =
					timeFrom: moment(from).format 'YYYY-MM-DD'
					timeTo: moment(to).format 'YYYY-MM-DD'
					metrics: [metric]
					items: [
						id: '24477009638'
						type: 'fb-insights'
					,
						id: '1588524668099814'
						type: 'fb-insights'
					,
						id: '1497945420520561'
						type: 'fb-insights'
					,
						id: '1627700970844024'
						type: 'fb-insights'
					]

				heraRemote.post "metricsApi", params, (err, res) ->
					return next err if err

					for item in res.items
						{values} = item

						name = desigualKpiConfigMain.fb_profile_names[item.id]

						out.facebook.reach[name] ?=
							total: 0
							change: 0

						out.facebook.reach[name].total = values[values.length - 1].B or 0

						if timerange is 'last day'
							out.facebook.reach[name].change = out.facebook.reach[name].total - values[values.length - 2].B
							for i in [values.length - 7..values.length - 1]
								out.facebook.reach[name].evolution.push values[i].B or 0
						else if timerange is 'last 7 days'
							out.facebook.reach[name].change = out.facebook.reach[name].total - values[values.length - 8].B
							for i in [values.length - 7..values.length - 1]
								out.facebook.reach[name].evolution.push values[i].B or 0
						else
							out.facebook.reach[name].change = out.facebook.reach[name].total - values[values.length - 29].B
							for i in [values.length - 28..values.length - 1]
								out.facebook.reach[name].evolution.push values[i].B or 0

					next()

			# calculate instagram
			(next) ->
				to = new Date()
				from = new Date()
				to.setDate to.getDate() - 1

				switch timerange
					when "last day"
						from.setDate from.getDate() - 1 - 6
					when "last 7 days"
						from.setDate from.getDate() - 7 - 7
					when "last 28 days"
						from.setDate from.getDate() - 28 - 28

				params =
					timeFrom: moment(from).format 'YYYY-MM-DD'
					timeTo: moment(to).format 'YYYY-MM-DD'
					metrics: [
						'followedby_count_lifetime_by_day'
						'profile_interaction_count_per_1000_followedby_by_day'
					]
					items: [
						id: '2290918'
						type: 'ig-profile'
					]

				heraRemote.post "metricsApi", params, (err, res) ->
					return next err if err

					for name, metric of res.map
						{values} = res.items[0]

						if metric is 'followedby_count_lifetime_by_day'
							out.instagram.fans = values[values.length - 1][name] or 0

							if timerange is 'last day'
								out.instagram.fans_change = out.instagram.fans - values[values.length - 2][name]
							else if timerange is 'last 7 days'
								out.instagram.fans_change = out.instagram.fans - values[values.length - 8][name]
							else
								out.instagram.fans_change = out.instagram.fans - values[values.length - 29][name]

						if metric is 'profile_interaction_count_per_1000_followedby_by_day'
							if timerange is 'last day'
								out.instagram.interactions = values[values.length - 1][name]
								out.instagram.interactions_change = out.instagram.interactions - values[values.length - 2][name]

								for i in [values.length - 7..values.length - 1]
									out.instagram.interactions_evolution.push values[i][name] or 0
							else if timerange is 'last 7 days'
								for i in [values.length - 7..values.length - 1]
									out.instagram.interactions += values[i][name] or 0
									out.instagram.interactions_change += values[i][name] - values[i - 7][name]
									out.instagram.interactions_evolution.push values[i][name] or 0
							else
								for i in [values.length - 28..values.length - 1]
									out.instagram.interactions += values[i][name] or 0
									out.instagram.interactions_change += values[i][name] - values[i - 7][name]
									out.instagram.interactions_evolution.push values[i][name] or 0

					next()
		], (err) ->
			next err, out

	getTimeranges = ({}, next) ->
		next null, desigualKpiConfigMain.timeranges

	getCountries = ({}, next) ->
		next null, desigualKpiConfigMain.countries

	{getData, getTimeranges, getCountries}

module.exports =
	humanize: (value = 0, fixed = 0) ->
		s = ['', 'K', 'M', 'B']
		e = Math.floor(Math.log(Math.abs(value)) / Math.log 1000)
		(value / Math.pow(1000, e)).toFixed(fixed) + s[e]

	format: (value = 0, fixed = 0, symbol = " ") ->
		parts = value.toFixed(fixed).split "."
		parts[0] = parts[0].replace /\B(?=(\d{3})+(?!\d))/g, "#{symbol}"
		parts.join "."

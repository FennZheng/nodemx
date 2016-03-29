Http = require('http')

exports.httpGet = (options, cb)->
	req = Http.request(options, (res)->
		res.setEncoding('utf-8')
		data = ''
		res.on('data', (chunk)->
			data += chunk
		)
		res.on("end", ->
			cb(null, data)
		)
	)
	req.on("error", (err)->
		cb(err, null)
	)
	req.end()
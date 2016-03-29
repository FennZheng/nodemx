Url = require("url")
HttpUtils = require("./http_utils")

_buildHttpOptions = (clientUrl, nodeNS)->
	url = "http://" + clientUrl + "/get/" + nodeNS

	_options = Url.parse(url)
	_options.method = "GET"
	_options.header = {
		"Content-Type": "application/json"
	}
	_options


fetchNodeNS = (clientUrl, nodeNS, cb)->
	_clientNsOptions = _buildHttpOptions(clientUrl, nodeNS)
	HttpUtils.httpGet(_clientNsOptions, (err, result)->
		try
			if not result
				return cb(null, null)
			_tmp = JSON.parse(result)
			cb(null, _tmp)
		catch err
			console.log("sss："+err.stack)
			cb(err, null)
	)

exports.fetchNodeNS = fetchNodeNS

###
    "keywords": {
		"createSocketCount": 3033,
		"closeSocketCount": 3033,
		"errorSocketCount": 0,
		"timeoutSocketCount": 1658,
		"requestCount": 2544,
		"freeSockets": {},
		"sockets": {},
		"requests": {}
	},
###
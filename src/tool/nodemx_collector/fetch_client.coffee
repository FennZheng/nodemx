Config = require("./nodemx.json")
HttpUtils = require("./http_utils")
_optionsRegistryCenter = Config.hadesHttpOption

fetchAllClientUrls = (cb)->
	HttpUtils.httpGet(_optionsRegistryCenter, (err, result)->
		try
			if not result
				return cb(null, null)
			_clientUrls = []
			_tmp = JSON.parse(result)
			for _item in _tmp
				_clientUrls.push _item if _item
			cb(null, _clientUrls)
		catch err
			console.log("fetchAllClientUrls error:"+err.stack)
			cb(err, null)
	)

exports.fetchAllClientUrls = fetchAllClientUrls
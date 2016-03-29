Async = require("async")
FetchClient = require("./fetch_client")
FetchMBean = require("./fetch_mbean")
SlinkGraphite = require("./slink_graphite")
test = true

THIRD_PARTY_AD_HTTP_AGENT_NS = "ad.third_party_ad:http_agent"

collect = (cb)->
	FetchClient.fetchAllClientUrls((err, clientUrls)->
		if not clientUrls
			console.log("No client registered")
			return cb(null, null)

		socketCounter = {}

		Async.map(clientUrls
		,(clientUrl, _cb)->
			_ip = clientUrl.split(":")?[0]
			FetchMBean.fetchNodeNS(clientUrl, THIRD_PARTY_AD_HTTP_AGENT_NS, (err, result)->
				if result
					for _dspName of result
						_statistic = result[_dspName]
						continue if not _statistic

						if not socketCounter[_ip]
							socketCounter[_ip] = {}
						if not socketCounter[_ip][_dspName]
							socketCounter[_ip][_dspName] = {}
							socketCounter[_ip][_dspName].usingCount = 0
							socketCounter[_ip][_dspName].freeCount = 0

						socketCounter[_ip][_dspName].usingCount += (_statistic.createSocketCount - _statistic.closeSocketCount)

						_freeSocketCount = 0
						for url of _statistic.freeSockets
							_freeSocketCount += _statistic.freeSockets[url]
						socketCounter[_ip][_dspName].freeCount += _freeSocketCount

				_cb(null, null)
			)
		,(err, reuslt)->
			if err
				console.log("fetchAllClientUrls error:"+err.stack)
			cb(err, socketCounter)
		)
	)

_startTime = Date.now()
collect((err, socketCounter)->
	if not socketCounter
		console.log("socketCounter is empty")
		return

	for _ip of socketCounter
		_dspGroup = socketCounter[_ip]
		for _dspName of _dspGroup
			_usingCountMsg = SlinkGraphite.buildSocketUsingCountPath(_ip, _dspName, _dspGroup[_dspName].usingCount)
			_freeCountMsg = SlinkGraphite.buildSocketFreeCountPath(_ip, _dspName, _dspGroup[_dspName].freeCount)
			if test
				console.log("_usingCountMsg:"+_usingCountMsg)
				console.log("_freeCountMsg:"+_freeCountMsg)
			else
				SlinkGraphite.sendToGraphite(_usingCountMsg)
				SlinkGraphite.sendToGraphite(_freeCountMsg)
	console.log("collect finished cost:"+(Date.now()-_startTime))
	return
)

process.on('uncaughtException', (err)->
	console.log("uncaughtException error:"+err.stack)
)
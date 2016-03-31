Async = require("async")
FetchClient = require("./fetch_client")
FetchMBean = require("./fetch_mbean")
SlinkGraphite = require("./slink_graphite")
test = true

REDIS_CLIENT_CMD_STATISTIC_NS = "ad.redis_client:cmd_statistic"

collect = (cb)->
	FetchClient.fetchAllClientUrls((err, clientUrls)->
		if not clientUrls
			console.log("No client registered")
			return cb(null, null)

		cmdCounter = {}

		Async.map(clientUrls
		,(clientUrl, _cb)->
			_ip = clientUrl.split(":")?[0]
			FetchMBean.fetchNodeNS(clientUrl, REDIS_CLIENT_CMD_STATISTIC_NS, (err, statistic)->
				if statistic
					if not cmdCounter[_ip]
						cmdCounter[_ip] = {}
						cmdCounter[_ip]["cmd_count"] = 0
						cmdCounter[_ip]["cmd_error_count"] = 0
					cmdCounter[_ip]["cmd_count"] += statistic.lastMinuteCmdCount
					cmdCounter[_ip]["cmd_error_count"] += statistic.lastMinuteErrorCount
				_cb(null, null)
			)
		,(err, reuslt)->
			if err
				console.log("fetchAllClientUrls error:"+err.stack)
			cb(err, cmdCounter)
		)
	)

_startTime = Date.now()
collect((err, cmdCounter)->
	if not cmdCounter
		console.log("cmdCounter is empty")
		return

	for _ip of cmdCounter
		_statisticObj = cmdCounter[_ip]
		_cmdCountMsg = SlinkGraphite.buildRedisClientCmdCountPath(_ip, _statisticObj["cmd_count"])
		_cmdErrorCountMsg = SlinkGraphite.buildRedisClientCmdErrorCountPath(_ip, _statisticObj["cmd_error_count"])
		if test
			console.log("_cmdCountMsg:"+_cmdCountMsg)
			console.log("_cmdErrorCountMsg:"+_cmdErrorCountMsg)
		else
			SlinkGraphite.sendToGraphite(_cmdCountMsg)
			SlinkGraphite.sendToGraphite(_cmdErrorCountMsg)

	console.log("collect finished cost:"+(Date.now()-_startTime))
	return
)

process.on('uncaughtException', (err)->
	console.log("uncaughtException error:"+err.stack)
)
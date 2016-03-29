Dgram = require("dgram")
StatsdConfig = require("./nodemx.json").statsdConfig

formatIp = (ip)->
	ip.replace(/\./g, "_")

exports.buildSocketUsingCountPath = (ip, dspCode, count)->
	ip = formatIp(ip)
	"microlens.hermes.pub.hadn." + ip + ".third_party.dsp."+dspCode+".http_agent.connection.using"+":"+count+"|g"

exports.buildSocketFreeCountPath = (ip, dspCode, count)->
	ip = formatIp(ip)
	"microlens.hermes.pub.hadn." + ip + ".third_party.dsp."+dspCode+".http_agent.connection.idle"+":"+count+"|g"

exports.buildCookieClientCmdCountPath = (ip, count)->
	ip = formatIp(ip)
	"microlens.hermes.pub.hadn." + ip + ".cookie_client.counters.cmd_count:"+count+"|g"

exports.buildCookieClientCmdErrorCountPath = (ip, count)->
	ip = formatIp(ip)
	"microlens.hermes.pub.hadn." + ip + ".cookie_client.counters.cmd_error_count:"+count+"|g"

exports.sendToGraphite = (data)->
	socket = Dgram.createSocket("udp4")
	socket.bind(->
		socket.setBroadcast(true)
	)
	message = new Buffer(data);
	socket.send(message, 0, message.length, StatsdConfig.port, StatsdConfig.ip, (err, bytes)->
		if err
			console.log("sendToGraphite error:"+err.stack)
		socket.close()
	)

###
    microlens.hermes.pub.third_party_ad.dsp_http_agent.{machineIp}.{dspCode}.req_count
###
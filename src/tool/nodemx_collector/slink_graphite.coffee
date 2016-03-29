Dgram = require("dgram")
StatsdConfig = require("./nodemx.json").statsdConfig

exports.buildSocketUsingCountPath = (ip, dspCode, count)->
	ip = ip.replace(/\./g, "_")
	"microlens.hermes.pub.hadn." + ip + ".third_party.dsp."+dspCode+".http_agent.connection.using"+":"+count+"|g"

exports.buildSocketFreeCountPath = (ip, dspCode, count)->
	ip = ip.replace(/\./g, "_")
	"microlens.hermes.pub.hadn." + ip + ".third_party.dsp."+dspCode+".http_agent.connection.idle"+":"+count+"|g"

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
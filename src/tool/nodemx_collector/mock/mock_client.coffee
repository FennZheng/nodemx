Dgram = require("dgram")
SlinkGraphite = require("./../slink_graphite")

sendToGraphite = (data)->
	socket = Dgram.createSocket("udp4")
	socket.bind(->
		socket.setBroadcast(true)
	)
	message = new Buffer(data);
	socket.send(message, 0, message.length, 41234, '127.0.0.1', (err, bytes)->
		socket.close()
	)

_data = SlinkGraphite.buildSocketUsingCountPath("192.168.113.171", "miaozhen", 200)
console.log(_data)
sendToGraphite(_data)
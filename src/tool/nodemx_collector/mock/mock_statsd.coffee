Dgram = require("dgram")
server = Dgram.createSocket("udp4")
server.on("error", (err)->
	console.log("server error:\n" + err.stack)
	server.close()
)

server.on("message", (msg, clientInfo)->
	console.log("server got: "+ msg+ " from "+ clientInfo.address + ":" + clientInfo.port)
)

server.on("linstening", ->
	address = server.address()
	console.log("server listening "+ address.address+ ":" + address.port)
)
server.bind(41234)
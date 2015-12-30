Http = require('http')
###
   协议定义part1：
    req url: #{host:port}/get/${name}
    如
        127.0.0.1:59573/get/ad.memory:usage
    res: {
		"" 如果是子节点则返回html，如果是bean则返回json
    }
###
path1 = "/get/"
path2 = "/get/ad"
path3 = "/get/ad.memory"
path4 = "/get/ad.memory:usage"

options = {
	host: "127.0.0.1",
	path: "/get/",
	port: 59573
}

options.method = "GET"
options.headers = {}
options.headers['Content-Type'] = 'application/json'

req = Http.request(options, (res)->
	res.setEncoding('utf8')
	data = ''
	res.on('data', (chunk)->
		data += chunk
	)
	res.on("end", ()->
		console.log(res.statusCode)
		console.log(data)
	)
)
req.on("error", (err)->
	console.error("req error:"+err.stack)
)
req.end()



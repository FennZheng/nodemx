Http = require('http')
###
    协议定义part2：
    req url: #{host:port}/invoke/${beanName}/${funcName}/${param1},#{param2},#{param3}
    如
        127.0.0.1:59573/invoke/ad/getAddById/1101
    res: {

    }
###
path2 = "/invoke/ad.memory:usage2/getAddById/1101"

options = {
	host: "127.0.0.1",
	path: path2,
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



###
    协议定义part2：
    req url: #{host:port}/invoke/${beanName}/${funcName}/${param1},#{param2},#{param3}
    如
        127.0.0.1:59573/invoke/ad/getAddById/11011
    res: {

    }
###
Http = require('http')
reqBody = {
	"method": "invoke",
	"name": "ad.memory:usage2",
	"funcName": "getAddById",
	"params": ["1101"]
}

reqData = JSON.stringify(reqBody)
options = {
	host: "127.0.0.1",
	path: "/",
	port: 59573
}

options.method = "POST"
options.headers = {}
options.headers['Content-Type'] = 'application/json'
options.headers['Content-Length'] = Buffer.byteLength(reqData, 'utf8')

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
req.write(reqData)
req.on("error", (err)->
	console.error("req error:"+err.stack)
)
req.end()

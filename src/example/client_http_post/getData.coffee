Http = require('http')
###
   协议定义：
    req: {
		method:"",//get set invoke
        name:"",
        param:[],
    }
    res: {
		name: "",
        param: [],
        result: ""(json type)
    }
###
reqBody = {
	"method": "get",
	"name": "ad"
}
###
reqBody = {
	"method": "get",
	"name": "ad.memory:usage"
}

###
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



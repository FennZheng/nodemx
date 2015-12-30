Http = require('http')
Url = require('url')
EventEmitter = require("events").EventEmitter
MBeanManager = require("./mbean_manager").MBeanManager
Log = require("./log").Log

###
Method POST协议定义：
    req: {
		method:"",//get set invoke
        name:"",
        param:[],
    }
    res: {
		name: "",
        result: ""(json)
    }
###
###
Method GET协议定义：
    req url: #{host:port}/get/${name}
    如
        127.0.0.1:59573/get/ad.memory:usage
    res: {
		"" 如果是子节点则返回html，如果是bean则返回json
    }
###

METHOD_GET = "get"
METHOD_SET = "set"
METHOD_INVOKE = "invoke"

class MBServer extends EventEmitter
	constructor: (serverName, adaptor)->
		@serverName = serverName
		@_adaptor = adaptor
		@_mbeanManager = new MBeanManager()

	start: (port)->
		self = @
		server = Http.createServer((req, res)->
			data = ""
			req.on("data", (chunk)->
				data += chunk
			)
			req.on("end", ->
				req.reqBody = data
				self._handler(req, res)
			)
		)
		server.on('listening', ->
			self.emit("started", server.address().port)
		)
		server.on('error', (err)->
			self.emit("error", err)
		)
		if port
			server.listen(port)
		else
			server.listen(0)

	register: (mbean)->
		@_mbeanManager.register(mbean)

	unRegister: (mbean)->
		@_mbeanManager.unRegister(mbean)

	_handler: (req, res)->
		try
			if req.method is "POST"
				reqBody = req.reqBody
				if not reqBody
					@_sendEmpty(req, res)
				else
					@_resolvePost(req, res)
			else if req.method is "GET"
				pathname = Url.parse(req.url).pathname
				# 处理path中多余部分--start
				# 去掉开头的/，如果有的话
				if pathname.substring(0, 1) is "/"
					pathname = pathname.substring(1, pathname.length)
				# 去掉结尾的/，如果有的话
				if pathname.substring(pathname.length-1, pathname.length) is "/"
					pathname = pathname.substring(0, pathname.length-1)
				# 处理path中多余部分--end

				# pathname必须是get 开头，且后面没有多个/
				if not pathname or pathname is 'favicon.ico'
					@_sendEmpty(req, res)
				else if pathname.indexOf("get") is 0
					req.reqBody = pathname.substring(4, pathname.length)
					@_resolveGet(req, res)
				else if pathname.indexOf("invoke") is 0
					_parts = pathname.substring(7, pathname.length).split("/")
					if _parts.length >= 2
						_name = _parts[0]
						_funcName = _parts[1]
						_params = []
						if _parts.length > 2
							args = _parts[2]
							for arg in args.split(",")
								_params.push arg
						#FIXME get param无法区分int和string
						convertData = @_adaptor.convert(_name, @_mbeanManager.invokeFunc(_name, _funcName, _params))
						@_sendOk(req, res, convertData)
					else
						@_sendEmpty(req, res)
				else
					@_sendEmpty(req, res)
			else
				@_sendMethodNotAllow(req, res)
		catch err
			Log.error("_handler error:"+err.stack)
			@_sendError(req, res, err.stack)

	_resolveGet: (req, res)->
		try
			name = req.reqBody
			convertData = @_adaptor.convert(name, @_mbeanManager.getBeanOrNsChild(name))
			@_sendOk(req, res, convertData)
		catch err
			Log.error("JsonAdaptor _resolveGet error:"+err.stack)

	_resolvePost: (req, res)->
		try
			reqObj = JSON.parse(req.reqBody)
			if reqObj.method is METHOD_GET
				convertData = @_adaptor.convert(reqObj.name, @_mbeanManager.getBeanOrNsChild(reqObj.name))
				@_sendOk(req, res, convertData)
			else if reqObj.method is METHOD_SET
				@_sendOk(req, res)
			else if reqObj.method is METHOD_INVOKE
				convertData = @_adaptor.convert(reqObj.name, @_mbeanManager.invokeFunc(reqObj.name, reqObj.funcName, reqObj.params))
				@_sendOk(req, res, convertData)
			else
				@_sendEmpty(req, res)
		catch err
			Log.error("JsonAdaptor _resolvePost error:"+err.stack)

	_sendOk: (req, res, convertData)->
		convertData = {data:"", type:"json"} if not convertData or not convertData.data

		if convertData.type is "json"
			res.writeHead(200, {
				'Content-Type' : 'application/json',
				'Content-Length' : Buffer.byteLength(convertData.data, 'utf8')
			})
		else
			res.writeHead(200, {
				'Content-Type' : 'text/html',
				'Content-Length' : Buffer.byteLength(convertData.data, 'utf8')
			})
		res.write(convertData.data)
		res.end()

	_sendEmpty: (req, res)->
		res.writeHead(204, {
			'Content-Type' : 'application/json',
			'Content-Length' : 0
		})
		res.end()

	_sendMethodNotAllow: (req, res)->
		res.writeHead(405, {
			'Content-Type' : 'application/json',
			'Content-Length' : 0
		})
		res.end()

	_sendError: (req, res, errStack)->
		res.writeHead(500, {
			'Content-Type' : 'application/json',
			'Content-Length' : 0
		})
		res.write(errStack)
		res.end()

exports.MBServer = MBServer








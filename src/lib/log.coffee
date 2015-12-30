require("./../util/date.js")

class Log
	constructor : ->
		@_logger = null
		@_hasLogger = false
		@isDebugEnable = false

	init : (logger)->
		if not logger
			console.log("nodemx use console.log instead, cause by: logger is null")
			return
		@_logger = logger
		@_hasLogger = true
		@isDebugEnable = logger.isDebugEnable?()

	debug : (msg)->
		if @_hasLogger
			@_logger.debug(msg)
		else
			console.log("[#{@_getTime()}][nodemx][DEBUG] #{msg}") if @isDebugEnable

	info : (msg)->
		if @_hasLogger
			@_logger.info(msg)
		else
			console.log("[#{@_getTime()}][nodemx][INFO] #{msg}")

	error : (msg)->
		if @_hasLogger
			@_logger.error(msg)
		else
			console.error("[#{@_getTime()}][nodemx][ERROR] #{msg}")

	_getTime : ->
		new Date().format("yyyy-MM-dd HH:mm:ss.S")

_instance = new Log()

init = (logger)->
	_instance.init(logger)

exports.Log = _instance
exports.init = init
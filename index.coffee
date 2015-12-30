Log = require("./src/lib/log")

exports.Adaptor = require("./src/lib/adaptor")
exports.ObjectMBean = require("./src/lib/mbeans").ObjectMBean
exports.MBServer = require("./src/lib/mbserver").MBServer
exports.initLog = (logger)->
	Log.init(logger)
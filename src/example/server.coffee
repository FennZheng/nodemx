nodemx = require("../../index")
Adaptor = nodemx.Adaptor
ObjectMBean = nodemx.ObjectMBean
MBServer = nodemx.MBServer

#mbServer = new MBServer("testServer", new Adaptor.JsonAdaptor())
mbServer = new MBServer("testServer", new Adaptor.HtmlAdaptor())

obj = {
	"1101": "我是1101"
	getAddById: (id)->
		console.log("obj getAddById is invoked ,param id:"+id)
		console.log(obj[id])
		return obj[id]
	beanExport: ->
		return process.memoryUsage()
}
#name 结构：名称
memoryMbean1 = new ObjectMBean("ad.memory:usage1", obj)
memoryMbean2 = new ObjectMBean("ad.memory:usage2", obj)
memoryMbean3 = new ObjectMBean("ad.memory3:usage3", obj)

mbServer.on("started", (port)->
	console.log("mbServer started at port:#{port}")
)
mbServer.on("error", (err)->
	console.log("mbServer error:#{err?.stack}")
)

mbServer.start(59573)

mbServer.register(memoryMbean1)
mbServer.register(memoryMbean2)
mbServer.register(memoryMbean3)
mbServer.unRegister(memoryMbean1)

process.on("uncaughtException", (err)->
	console.log("uncaughtException error:"+err.stack)
)
###
    所有的ObjectBean必须有
###
class ObjectMBean
	constructor: (name, obj)->
		@type = "object"
		@name = name
		@_obj = obj

ObjectMBean.get = (objectBean)->
	if objectBean._obj and objectBean._obj.beanExport
		return objectBean._obj.beanExport()
	else
		return null

ObjectMBean.set = (key, value)->
	return null

ObjectMBean.invoke = (objectBean, funcName, params)->
	if objectBean._obj
		_func = objectBean._obj[funcName]
		if _func and typeof _func is 'function'
			return _func.apply(objectBean, params)
	return null

exports.ObjectMBean = ObjectMBean
ObjectMBean = require("./mbeans").ObjectMBean
Log = require("./log").Log

###
    MBeanManager:
    如 vernon.mbeans:memory, 则注册后存储结构为：根节点没有.，而其他节点都有前缀
        @_namespaceIndex: {
            vernon:{
                .mbeans:{
                    :memory
                }
            }
        }
        @_mbeans: {"vernon.mbeans:memory": mbean}

###

class MBeanManager
	constructor: ->
		@_namespaceIndex = {}
		@_mbeans = {}

	register: (mbean)->
		if not mbean
			throw new Error("register fail: mbean is null")
		else if @_mbeans[mbean.name]
			throw new Error("register fail: mbean[#{mbean.name}] has been registered")
		else
			@_mbeans[mbean.name] = mbean
			@_updateNsIndex(mbean.name)

	_updateNsIndex: (name)->
		_beanInfo = @_resolveBeanInfo(name)
		_nsLiteral = _beanInfo.nsLiteral
		_type = _beanInfo.type

		_nsNode = @_findOrCreateNsNode(_nsLiteral)
		return false if not _nsNode

		_nsNode[@_wrapTypeNode(_type)] = true
		return true

	# 找到namespace节点, 没有中间节点则创建
	_findOrCreateNsNode: (nsLiteral)->
		return null if not nsLiteral or nsLiteral.length <= 0
		_nsNode = @_namespaceIndex

		# 根节点特殊处理
		_rootNodeName = nsLiteral[0]
		_nsNode[_rootNodeName] = {} if not _nsNode[_rootNodeName]
		_nsNode = _nsNode[_rootNodeName]

		for childrenNode in nsLiteral[1..nsLiteral.length]
			_nodeName = @_wrapNsNode(childrenNode)
			_nsNode[_nodeName] = {} if not _nsNode[_nodeName]
			_nsNode = _nsNode[_nodeName]

		return _nsNode

	_wrapNsNode: (node)->
		return null if not node or node is "." or node is ":"
		return "." + node

	_wrapTypeNode: (node)->
		return null if not node or node is "." or node is ":"
		return ":" + node

	# 子节点会删除，父节点会继续保留
	_removeNsIndex: (name)->
		_beanInfo = @_resolveBeanInfo(name)
		_nsLiteral = _beanInfo.nsLiteral
		_type = _beanInfo.type

		_nsNode = @_findOrCreateNsNode(_nsLiteral)
		return if not _nsNode
		delete _nsNode[@_wrapTypeNode(_type)]

	_resolveBeanInfo: (name)->
		if not name
			return {
				namespace: ""
				nsLiteral: []
				type: null
			}

		_nsAndType = name.split(":")
		if _nsAndType.length is 1
			return {
				namespace: _nsAndType[0],
				nsLiteral: _nsAndType[0].split("."),
				type: null
			}
		else if _nsAndType.length is 2
			return {
				namespace: _nsAndType[0],
				nsLiteral: _nsAndType[0].split("."),
				type: _nsAndType[1]
			}
		else
			throw new Error("_resolveBeanInfo error: bean.name[#{name}] is illegal")

	unRegister: (mbean)->
		if mbean and mbean.name
			delete @_mbeans[mbean.name]
			@_removeNsIndex(mbean.name)
			return true
		return false

	_fetchChildByNS: (beanInfo)->
		return @_lookupNSIndexChild(beanInfo.nsLiteral)

	_lookupNSIndexChild: (nsLiteral)->
		return null if not @_namespaceIndex

		_matchNode = @_namespaceIndex

		if nsLiteral and nsLiteral.length >0
			# 根节点特殊处理
			_matchNode = @_namespaceIndex[nsLiteral[0]]
			return null if not _matchNode

			for _ns in nsLiteral[1..nsLiteral.length]
				_nodeName = @_wrapNsNode(_ns)
				_matchNode = _matchNode[_nodeName]
				if not _matchNode
					return null

		# 此时_node子节点可能是ns，也可能是type
		_childrenNodes = []
		for childNode of _matchNode
			_childrenNodes.push childNode
		return _childrenNodes

	_fetchBeanInfo: (name)->
		_bean = @_mbeans[name]
		if _bean and _bean.type is "object"
			return ObjectMBean.get(_bean)
		return null

	_fetchBean: (name)->
		_bean = @_mbeans[name]
		if _bean and _bean.type is "object"
			return _bean
		return null

	invokeFunc: (beanName, funcName, paramArray)->
		try
			_bean = @_fetchBean(beanName)
			if _bean
				return ObjectMBean.invoke(_bean, funcName, paramArray)
			return "invoke fail: not found function for beanName:#{beanName}/funcName:#{funcName}"
		catch err
			Log.error("_invokeMethod error:"+err.stack)
			return err.stack

	# name
	getBeanOrNsChild: (name)->
		_beanInfo = @_resolveBeanInfo(name)
		# 有type则查找bean，没有则查找namespace索引
		if not _beanInfo.type
			return @_fetchChildByNS(_beanInfo)
		else
			return @_fetchBeanInfo(name)

exports.MBeanManager = MBeanManager
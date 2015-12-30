class HtmlAdaptor
	convert: (name, obj)->
		return @_generate(name, obj)

	_generate: (name, obj)->
		convertData = {type:"html", data:""}
		html = ""
		return convertData if not obj
		if name.indexOf(":") > 0
			#beanInfo
			html += JSON.stringify(obj, null, "\t")
			convertData.type = "json"
			convertData.data = html
		else
			#namespace
			for nsNodeChild in obj
				html += "<li>"
				# name 为null为root节点
				if not name
					_path = nsNodeChild
				else
					_path = name + nsNodeChild
				html += "<a href=\"/get/#{_path}\">"
				html += _path
				html += "</a>"
				html += "</li>"
			convertData.type = "html"
			convertData.data = html
		return convertData

class JsonAdaptor
	convert: (name, obj)->
		data = {}
		data.name = name
		data.result = obj
		return {type:"json", data:JSON.stringify(data)}


exports.JsonAdaptor = JsonAdaptor
exports.HtmlAdaptor = HtmlAdaptor
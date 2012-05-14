require 'coffee-script'
Message = require './Message.coffee'

class Router
	constructor: (@context, @name)->
		@routes = { }
		@lastId = 0
		
	register: (name, needSerialze, sender) ->
#		@routes[name] = { needSerialize: needSerialize, sender:  sender }
		@routes[name] = sender
		
	unregister: (name) ->
		delete @routes[name]
	# 
	# send: (dest, message, sender) ->
	# 	route = @routes[dest]	
	# 	
	# 	envolop = {
	# 		message: if route.needSerialize then message.serialize() else message
	# 		needCallback: message.callback?
	# 		id: @lastId
	# 		from: @name
	# 	}
	# 	
	# 	payload = if route.needSerialize then JSON.stringify envolop else envolop
	# 	route.sender.call(this, dest, payload)
	#  	 
	# recieve: (envolop) ->
	# 	if typeof(envolop) is 'string'
	# 		envolop = JSON.parse envolop
	# 		envolop.message = Message.deserialize envolop.message
	# 	
	#	if(needcallBack)
	
	route: (message) =>
		return message.deliverTo @context if message.routes.length == 0;
		
		dest = message.routes.shift()
		return @routes[dest].call(this, message, dest )
		
exports = module.exports = Router
require 'coffee-script'
Message = require './Message.coffee'

class Router
	constructor: (@context, @name)->
		@routes = { }
		@lastId = 0
		
	register: (name, option) ->
		option = { sender: option, needSerialize: false } if typeof(option) is "function"
		@routes[name] = option
		
	unregister: (name) ->
		delete @routes[name]
	
	getMessageId: =>
		@lastId = (@lastId + 1) % 65535
	
	send: (dest, message) =>
		route = @routes[dest]	
		throw "Invalid Route" unless route?
		
		envolop = {
			message: if route.serialize then message.serialize() else message
			needCallback: message.callback?
			id: this.getMessageId()
			from: @name
		}
		
		envolop = JSON.stringify(envolop) if route.serialize 
		route.sender.call(this, envolop, dest)	
	 	 
	recieve: (envolop) =>
		serialized = typeof(envolop) is 'string'
		if serialized
			envolop = JSON.parse envolop
			envolop.message = Message.deserialize envolop.message
		
		this.route envolop.message
	
	route: (message) =>
		return message.deliverTo @context if message.routes.length == 0;
		
		dest = message.routes.shift()

		return message.deliverTo @context if dest == @name
		
		this.send dest, message  
		
exports = module.exports = Router
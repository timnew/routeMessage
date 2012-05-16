require 'coffee-script'
Message = require './Message.coffee'

class Router
	constructor: (@context, @name)->
		@routes = { }
		@lastId = 0
		@callbackPool = { }
		
	register: (name, option) ->
		option = { sender: option, serialize: false } if typeof(option) is "function"
		@routes[name] = option
		
	unregister: (name) ->
		delete @routes[name]
	
	getMessageId: =>
		@lastId = (@lastId + 1) % 65535
	
	send: (dest, message, callbackId = null) =>
		route = @routes[dest]	
		throw "Invalid Route" unless route?
		
		if callbackId? 
			envolop = {
				message: if route.serialize then JSON.stringify(message) else message
				hasCallback : false
				id: callbackId
				isCallback: true
				from: @name
			}
		else
			envolop = {
				message: if route.serialize then message.serialize() else message
				hasCallback: message.callback?
				id: this.getMessageId()
				isCallback: false
				from: @name
			}
		
		@callbackPool[envolop.id] = message.callback if envolop.hasCallback 
		
		envolop = JSON.stringify(envolop) if route.serialize 
		
		route.sender.call(this, envolop, dest)	
	 	 
	recieve: (envolop) =>
		serialized = typeof(envolop) is 'string'
		if serialized
			envolop = JSON.parse envolop
			if envolop.isCallback
				envolop.message = JSON.parse envolop.message
			else
				envolop.message = Message.deserialize envolop.message
		
		if envolop.hasCallback
			sendCallback = this.send
			envolop.message.callback = (args...) ->
				sendCallback envolop.from, args, envolop.id
		
		if envolop.isCallback
			@callbackPool[envolop.id].apply(null, envolop.message)
			delete @callbackPool[envolop.id]
		else	
			this.route envolop.message
			
	route: (message) =>
		return message.deliverTo @context if message.routes.length == 0;
		
		dest = message.routes.shift()

		return message.deliverTo @context if dest == @name
		
		this.send dest, message  
		
exports = module.exports = Router
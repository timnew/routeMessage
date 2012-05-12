class Router
	constructor: (@name, @context) ->
		@routes = { }
		this.register @name, this.route
		
	register: (name, handler) ->
		@routes[name] = handler
	
	unregister: (name) ->
		delete @routes[name]

	route: (message) ->
		dest = message.route()
		if dest?
			@routes[dest]?(message, this)
		else
			message.deliverTo @context
		
exports = module.exports = Router
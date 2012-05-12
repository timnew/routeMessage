class Message
	constructor: (address, @params...) ->
		parts = address.split(':')
		@routes = parts[..-2]
		@path = parts[parts.length - 1].split('.')

	route: =>
		@routes.shift()

	deliverTo: (context, explictHost = null) =>
		[host,action] = Message.locate(context, @path)
		host = explictHost if explictHost?
		action.apply(host, @params)
		
Message.locate = (context, path) -> 
	member = context
	
	# [host, member] = [member, member[current]] for current in path
	for current in path
		host = member
		member = member[current]
	
	[host, member]

exports = module.exports = Message
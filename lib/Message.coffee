class Message
	constructor: (option, params...) ->
		if typeof(option) is 'string' 
			fullPath = option
			@callback = null
			@params = []
		else 
			fullPath = option.fullPath
			@callback = if option.callback? then option.callback else null
			@params = if option.params? then option.params else []
		 
		[@routes, @localPath] = Message.parsePath fullPath
		@params = params if params.length > 0

	deliverTo: (context, explictHost = null) =>
		[host,action] = Message.locate(context, @localPath)
		host = explictHost if explictHost?

		result = action.apply(host, @params)
		
		@callback(result) if @callback?
		
	serialize: =>
		JSON.stringify this

Message.parsePath = (fullPath) ->
	parts = fullPath.split ':'
	localPath = parts[parts.length - 1].split('.')
	[ parts[..-2], localPath ]
			
Message.locate = (context, localPath) -> 
	member = context
	
	# [host, member] = [member, member[current]] for current in path
	for current in localPath
		host = member
		member = member[current]
	
	[host, member]

Message.deserialize = (json) ->
	message = JSON.parse(json)
	message.__proto__ = Message.prototype
	message.constructor = Message
	message

exports = module.exports = Message
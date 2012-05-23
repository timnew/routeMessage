class Message
	constructor: (option, args...) ->
		if typeof(option) is 'string' 
			fullPath = option
			@returnCallback = null
			@args = []
		else 
			fullPath = option.fullPath
			@returnCallback = if option.returnCallback? then option.returnCallback else null
			@args = if option.args? then option.args else []
		 
		[@foriegnPath, @localPath] = Message.parsePath fullPath
		@args = args if args.length > 0

	deliverTo: (context, explictHost = null) =>
		[host,action] = Message.locate(context, @localPath)
		host = explictHost if explictHost?

		result = action.apply(host, @args)
		
		@returnCallback(result) if @returnCallback?
		
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
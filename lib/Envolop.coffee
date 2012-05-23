require 'coffee-script'

normalizeTypeName = (typeName) ->
	switch typeof(typeName)
		when "function" then typeName.name
		when "string" then typeName
		else getPayloadTypeName(typeName)

getPayloadTypeName = (payload) ->
	payload.constructor.name

detectPayloadType = (payload) ->
		payloadType = getPayloadTypeName(payload)
		payloadType = "generic" unless Envolop.knownTypes[payloadType]?
		payloadType

serializePayload = (payload) ->
	type = detectPayloadType(payload)
	Envolop.knownTypes[type].serializer(payload)

deserializePayload = (type, json) ->
	Envolop.knownTypes[type].deserializer(json)

class Envolop
	constructor: (@payload, @id = Envolop.newId()) ->
		@payloadType = detectPayloadType(@payload)
		
	serialize: => 
		payload = @payload
		@payload = serializePayload(payload)
		json = JSON.stringify this
		@payload = payload
		json

Envolop.deserialize = (json) ->
	envolop = JSON.parse(json)
	envolop.__proto__ = Envolop.prototype
	envolop.payload = deserializePayload(envolop.payloadType, envolop.payload)
	envolop

Envolop.knownTypes =
	generic:
		serializer: (payload) -> 
			JSON.stringify payload
		deserializer: (json) ->
			JSON.parse json	
	Message:
		serializer: (message) -> 
			message.serialize()
		deserializer: (json) ->
			Message.deserialize json

Envolop.registerType = (type, serializer, deserializer) ->
	type = normalizeTypeName type
	
	if typeof(serializer) is 'function'
		record = 
			serializer: serializer
			deserializer: deserializer
	else
	 	record = serializer
	
	Envolop.knownTypes[type] = record

Envolop.unregisterType = (type)	->
	type = normalizeTypeName type
	delete Envolop.knownTypes[type]

Envolop.lastId = 0	
Envolop.maxId = 65535
Envolop.newId = ->
	Envolop.lastId = (Envolop.lastId + 1) % Envolop.maxId
	
exports = module.exports = Envolop

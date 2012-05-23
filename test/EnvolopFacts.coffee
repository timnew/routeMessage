require 'coffee-script'
require('chai').should()

describe "Envolop", ->
	Envolop = require '../lib/Envolop.coffee'
	Message = require '../lib/Message.coffee'
	
	describe "Known Types", ->
		
		class TestPayload
		
		class UnknownPayload
		
		test = new TestPayload
		obj = 
			name: 'name'
			val: 123
		message = new Message('xx')
		unknown = new UnknownPayload
	
		envolopEqual = (expected, actual) ->
			actual.should.be.instanceOf Envolop
			actual.payload.should.eql expected.payload
			actual.id.should.eql expected.id
			actual.payloadType.should.eql expected.payloadType
				
		it "Should able to serialize normal object", ->
			envolop = new Envolop(obj)
			json = envolop.serialize()
			envolopClone = Envolop.deserialize(json)
			envolopEqual envolop, envolopClone

		it "Should able to register new type", ->
			new Envolop(test).payloadType.should.equal "generic"
		
			counter = 0
			
			Envolop.registerType "TestPayload",
				serializer:	(obj) ->
					counter++
					"testPayload"
				deserializer: (json) -> 
					json.should.equal("testPayload")
					new TestPayload
			
			envolop = new Envolop(test)
			envolop.payloadType.should.equal "TestPayload"
			
			envolopClone = Envolop.deserialize envolop.serialize()
			
			envolopEqual envolop, envolopClone
			counter.should.equal 1
			
			Envolop.unregisterType "TestPayload"
			
			new Envolop(test).payloadType.should.equal "generic"

		it "Should able to register new type with instance", ->
			new Envolop(test).payloadType.should.equal "generic"

			counter = 0

			Envolop.registerType test,
				serializer:	(obj) ->
					counter++
					"testPayload"
				deserializer: (json) -> 
					json.should.equal("testPayload")
					new TestPayload

			envolop = new Envolop(test)
			envolop.payloadType.should.equal "TestPayload"

			envolopClone = Envolop.deserialize envolop.serialize()

			envolopEqual envolop, envolopClone
			counter.should.equal 1

			Envolop.unregisterType test

			new Envolop(test).payloadType.should.equal "generic"
	
		it "Should able to register new type with constructor", ->
			new Envolop(test).payloadType.should.equal "generic"

			counter = 0

			Envolop.registerType TestPayload,
				serializer:	(obj) ->
					counter++
					"testPayload"
				deserializer: (json) -> 
					json.should.equal("testPayload")
					new TestPayload

			envolop = new Envolop(test)
			envolop.payloadType.should.equal "TestPayload"

			envolopClone = Envolop.deserialize envolop.serialize()

			envolopEqual envolop, envolopClone
			counter.should.equal 1

			Envolop.unregisterType TestPayload

			new Envolop(test).payloadType.should.equal "generic"
	
		it "Should able to register new type with 2 functions", ->
			new Envolop(test).payloadType.should.equal "generic"

			counter = 0

			Envolop.registerType TestPayload,
				(obj) ->
					counter++
					"testPayload"
				,
				(json) -> 
					json.should.equal("testPayload")
					new TestPayload

			envolop = new Envolop(test)
			envolop.payloadType.should.equal "TestPayload"

			envolopClone = Envolop.deserialize envolop.serialize()

			envolopEqual envolop, envolopClone
			counter.should.equal 1

			Envolop.unregisterType TestPayload

			new Envolop(test).payloadType.should.equal "generic"
	
	describe "Consturction", ->
		
		it "Should generate unique id until max id reached", ->
			maxId = Envolop.maxId
			
			Envolop.maxId = 16
			ids = []
			for i in [1..Envolop.maxId]
				id = Envolop.newId()
				ids.should.not.include id
				ids.push id
			
			Envolop.maxId = maxId
		
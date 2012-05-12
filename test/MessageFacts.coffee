require 'coffee-script'
require('chai').should()

describe "Message", ->
	Message = require '../lib/Message.coffee'
	
	it "Message should be exported correctly", ->
		Message.should.be.a("function").and.have.property('name','Message')
		Message.locate.should.be.a("function")
	
	it "Action should be located according to given path", ->
		context =  
			action: ->
			obj: 
				action: ->
				obj: 
					action: ->

		testCases = [
			{ host: context ,        action: context.action,         path: ["action"] },
			{ host: context.obj,     action: context.obj.action,     path: ["obj", "action"] }
			{ host: context.obj.obj, action: context.obj.obj.action, path: [ "obj", "obj", "action"] }
		] 
		
		for testCase in testCases
			[host, action] = Message.locate(context, testCase.path)
			host.should.equal testCase.host
			action.should.equal testCase.action
	
	it "Message should be constructed correctly", ->
		message = new Message("obj.subObj.action", 1, 2, 3, 4, 5)
		message.path.should.eql(["obj", "subObj", "action"])
		message.params.should.eql([1..5])
		
	it "Method defined on object should be invoked", (done) ->
		expectedArg = { }
		message = new Message("func", expectedArg)
		context = 
			func: (arg) -> 
				arg.should.equal(expectedArg)
				this.should.equal(expectedHost)
				done()
		
		expectedHost = context
		message.deliverTo context
		
	it "Method defined on this should be invoked", (done) ->
		expectedArg = { }
		message = new Message("func", expectedArg)

		this.func = (arg) -> 
				arg.should.equal(expectedArg)
				this.should.equal(expectedHost)
				done()
		
		expectedHost = this
		message.deliverTo this

	it "Method defined in deep object tree should be invoked", (done) ->
		expectedArg = { }
		message = new Message("obj1.obj2.obj3.func", expectedArg)
		context = 
			obj1:
				obj2:
					obj3:
						func: (arg) -> 
							arg.should.equal(expectedArg)
							this.should.equal(expectedHost)
							done()
		
		expectedHost = context.obj1.obj2.obj3
		message.deliverTo context
	
	it "Method should be invoked with explicit host", (done) ->
		expectedArg = { }
		message = new Message("obj1.obj2.obj3.func", expectedArg)
		context = 
			obj1:
				obj2:
					obj3:
						func: (arg) -> 
							arg.should.equal(expectedArg)
							this.should.equal(expectedHost)
							done()

		expectedHost = this
		message.deliverTo context, this
	
	it "deliverTo method should be able to keep its instance context", (done) ->
		expectedArg = { }
		message = new Message("func", expectedArg)
		context = 
			func: (arg) -> 
				arg.should.equal(expectedArg)
				this.should.equal(expectedHost)
				done()

		expectedHost = context
		
		wrapper = message.deliverTo
		wrapper context

	
		
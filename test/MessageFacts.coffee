require 'coffee-script'
require('chai').should()

describe "Message", ->
	Message = require '../lib/Message.coffee'
	
	describe "Object Construction", ->
		
		it "Message should be exported correctly", ->
			Message.should.be.a("function").and.have.property('name','Message')
			Message.locate.should.be.a("function")
		
		it "Message with remote path should be constructed correctly", ->
			message = new Message "aa:bb:cc:obj.action", 1, 2, 3, 4, 5
			
			message.localPath.should.eql ["obj", "action"]
			message.foriegnPath.should.eql ["aa","bb","cc"]
			message.args.should.eql [1..5]
		
		it "Message with local path should be constructed correctly", ->
			message = new Message "obj.subObj.action", 1, 2, 3, 4, 5
			
			message.localPath.should.eql ["obj", "subObj", "action"]
			message.foriegnPath.should.eql []
			message.args.should.eql [1..5]
		
		it "Message should be initialized correctly with options", ->
			returnCallback = ->
			args = [1..5]
			message = new Message {
				fullPath: "aa:bb:obj.action"
				returnCallback: returnCallback
				args: args
			}
			
			message.localPath.should.eql ["obj", "action"]
			message.foriegnPath.should.eql ["aa","bb"]
			message.args.should.eql [1..5]
			message.returnCallback.should.equal returnCallback
			
		it "Explicit args should overides the one in options", ->
			returnCallback = ->
			args = [1..5]
			message = new Message {
				fullPath: "aa:bb:obj.action"
				returnCallback: returnCallback
				args: args
			}, "a", "b", "c"

			message.localPath.should.eql ["obj", "action"]
			message.foriegnPath.should.eql ["aa","bb"]
			message.args.should.eql ["a", "b", "c"]
			message.returnCallback.should.equal returnCallback
			
	# end "Object Construction"
	
	describe "Serialization", ->
		it "Deserialized message should be still Message", ->
			message = new Message("foo:bar")
			messageClone = Message.deserialize(message.serialize())
			
			messageClone.should.be.instanceof(Message)
			
	#end "Serialization"
	
	describe "Basic delivery", ->
	
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

	# end "Basic delivery"		

	describe "Advanced delivery", ->
		
		it "Serialization", (done) ->
			expectedArgs = [ {a:{b:{c:"xx"}}}, 1.5, "3", [1..5] ]
			message = new Message("func")
			message.args = expectedArgs

			messageClone = Message.deserialize message.serialize()
			
			context = 
				func: (args...) -> 
					args.should.eql(expectedArgs)
					this.should.equal(expectedHost)
					done()

			expectedHost = context
		
			messageClone.deliverTo context
		
		it "Callback", (done) ->
			
			context = 
				assert: (res) ->
					res.should.equal(5)
					done()
					
				plusOne: (num) ->
					num + 1

			message = new Message({ fullPath: "plusOne", returnCallback: context.assert }, 4)
			message.deliverTo context
		
	# end "Route delivery"
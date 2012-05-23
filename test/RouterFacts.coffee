require 'coffee-script'
require('chai').should()

describe "Router", ->
	Message = require '../lib/Message.coffee'
	Router = require '../lib/Router.coffee'
	
	it "Should route message to correct context", (done) ->
		context = 
			verify: (arg) ->
				arg.should.equal('arg')
				done()

		message = new Message("foo:verify", "arg")

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")
		
		router1.registerRoute "foo", (payload) ->
			router2.recieve payload

		router1.route(message)
		
	it "Should short circuit the route process if name matches", (done) ->
		context = 
			verify: (arg) ->
				arg.should.equal('arg')
				done()
		
		contextFailure =
			verify: (arg) ->
				throw "wrong address"
		
		message = new Message("base:foo:verify", "arg")

		router1 = new Router(context, "base")
		router2 = new Router(contextFailure, "foo")
		
		router1.registerRoute "foo", (payload) ->
			router2.recieve payload

		router1.route(message)
		
	it "Should be able to serialize message during route if necessary", (done) ->
		context = 
			verify: (arg) ->
				arg.should.equal('arg')
				done()

		message = new Message("foo:verify", "arg")

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")
		
		router1.registerRoute "foo", 
			serialize: true
			sender: (payload) ->
				payload.should.be.a("string")
				router2.recieve payload
	
		router1.route(message)
	

	it "Should route callback", (done) ->
		context = 
			dest: (arg) ->
				arg.should.equal('arg')
				"callback #{arg}"
		
		returnCallback = (res) ->
			res.should.equal 'callback arg'
			done()

		message = new Message({ fullPath: "foo:dest", returnCallback: returnCallback }, 'arg')

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")

		router1.registerRoute "foo", (payload) -> 
			router2.recieve payload
		
		router2.registerRoute "base", (payload) ->
			router1.recieve payload 

		router1.route(message)
		
	it "searialized callback route", (done) ->
		context = 
			dest: (arg) ->
				arg.should.equal('arg')
				"callback #{arg}"
		
		returnCallback = (res) ->
			res.should.equal 'callback arg'
			done()

		message = new Message({ fullPath: "foo:dest", returnCallback: returnCallback }, 'arg')

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")

		router1.registerRoute "foo", { 
			serialize: true
			sender:	(payload) -> 
				router2.recieve payload
		}
		
		router2.registerRoute "base", {
			serialize: true
			sender: (payload) ->
				router1.recieve payload 
		}
		
		router1.route(message)
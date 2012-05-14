require 'coffee-script'
require('chai').should()

describe "Router", ->
	Message = require '../lib/Message.coffee'
	Router = require '../lib/Router.coffee'
	
	it "simple route", (done) ->
		context = 
			verify: (arg) ->
				arg.should.equal('arg')
				done()
		
		message = new Message("foo:verify", "arg")
		
		router = new Router(context)
		router.register "foo", false, (message, dest) ->
			dest.should.be.equal("foo")
			this.route(message)
			
		router.route(message)
		
	it "serialize route", (done) ->
		context = 
			verify: (arg) ->
				arg.should.equal('arg')
				done()

		message = new Message("foo:verify", "arg")

		router1 = new Router(null)
		router2 = new Router(context)
		
		router1.send = (message) ->
			router2.recieve(message.serialize())
			
		router2.recieve = (json) ->
			message = Message.deserialize(json)
			this.route message
		
		router1.register "foo", false, (message, dest) ->
			json = message.serialize()
			router2.recieve(json)

		router1.route(message)
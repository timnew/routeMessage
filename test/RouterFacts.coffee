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

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")
		
		router1.register "foo", (payload) ->
			router2.recieve payload

		router1.route(message)
		
	it "shortcut route", (done) ->
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
		
		router1.register "foo", (payload) ->
			router2.recieve payload

		router1.route(message)
		
	it "serialized route", (done) ->
		context = 
			verify: (arg) ->
				arg.should.equal('arg')
				done()

		message = new Message("foo:verify", "arg")

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")
		
		router1.register "foo", {
			serialize: true
			sender: (payload) ->
				router2.recieve payload
		}
	 
		router1.route(message)
	

	it "callback route", (done) ->
		context = 
			dest: (arg) ->
				arg.should.equal('arg')
				"callback #{arg}"
		
		callback = (res) ->
			res.should.equal 'callback arg'
			done()

		message = new Message({ fullPath: "foo:dest", callback: callback }, 'arg')

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")

		router1.register "foo", (payload) -> 
			router2.recieve payload
		
		router2.register "base", (payload) ->
			router1.recieve payload 

		router1.route(message)
		
	it "searialized callback route", (done) ->
		context = 
			dest: (arg) ->
				arg.should.equal('arg')
				"callback #{arg}"
		
		callback = (res) ->
			res.should.equal 'callback arg'
			done()

		message = new Message({ fullPath: "foo:dest", callback: callback }, 'arg')

		router1 = new Router(null, "base")
		router2 = new Router(context, "foo")

		router1.register "foo", { 
			serialize: true
			sender:	(payload) -> 
				router2.recieve payload
		}
		
		router2.register "base", {
			serialize: true
			sender: (payload) ->
				router1.recieve payload 
		}
		
		router1.route(message)
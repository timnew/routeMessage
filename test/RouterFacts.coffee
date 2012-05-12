require "coffee-script"
require("chai").should()

describe "Router", ->
	Message = require '../lib/Message.coffee'
	Router = require '../lib/Router.coffee'
	
	
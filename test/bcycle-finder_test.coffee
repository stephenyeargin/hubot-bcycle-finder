chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'hubot-bcycle-finder', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/bcycle-finder')(@robot)

  it 'registers bcycle listener', ->
    expect(@robot.respond).to.have.been.calledWith(/bcycle$/i)

  it 'registers bcycle list listener', ->
    expect(@robot.respond).to.have.been.calledWith(/bcycle list$/i)

  it 'registers bcycle me <station id> listener', ->
    expect(@robot.respond).to.have.been.calledWith(/bcycle me \#?([0-9]+)$/i)

  it 'registers bcycle search <query> listener', ->
    expect(@robot.respond).to.have.been.calledWith(/bcycle search (.*)$/i)

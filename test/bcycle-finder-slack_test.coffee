Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'

expect = chai.expect

helper = new Helper [
  'adapters/slack.coffee',
  '../src/bcycle-finder.coffee'
]

describe 'hubot-bcycle-finder slack', ->
  beforeEach ->
    nock.disableNetConnect()

    nock('https://gbfs.bcycle.com')
      .get('/bcycle_nashville/system_information.json')
      .replyWithFile(200, __dirname + '/fixtures/system_information.json')
    nock('https://gbfs.bcycle.com')
      .get('/bcycle_nashville/system_pricing_plans.json')
      .replyWithFile(200, __dirname + '/fixtures/system_pricing_plans.json')
    nock('https://gbfs.bcycle.com')
      .get('/bcycle_nashville/station_information.json')
      .replyWithFile(200, __dirname + '/fixtures/station_information.json')
    nock('https://gbfs.bcycle.com')
      .get('/bcycle_nashville/station_status.json')
      .replyWithFile(200, __dirname + '/fixtures/station_status.json')

  afterEach ->
    nock.cleanAll()

  # hubot bcycle
  context 'default stations tests', ->
    beforeEach ->
      process.env.BCYCLE_CITY = 'nashville'
      process.env.BCYCLE_DEFAULT_STATIONS='2162,2165'
      @room = helper.createRoom()

    afterEach ->
      @room.destroy()
      delete process.env.BCYCLE_CITY
      delete process.env.BCYCLE_DEFAULT_STATIONS

    it 'returns the status of the default stations', (done) ->
      selfRoom = @room
      selfRoom.user.say('alice', '@hubot bcycle')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle']
            [
              'hubot',
              {
                "attachments": [
                  {
                    "author_icon": "https://github.com/bcycle.png"
                    "author_link": "https://nashville.bcycle.com/"
                    "author_name": "BCycle"
                    "color": "good"
                    "fallback": "#2162 - Commerce & 2nd Ave N > Active | Bikes: 12 | Docks: 3"
                    "fields": [
                      {
                        "short": false
                        "title": "Address"
                        "value": "<https://www.google.com/maps/place/36.16309,-86.77612|204 Commerce Ave.>"
                      }
                      {
                        "short": true
                        "title": "Bikes Available"
                        "value": 12
                      }
                      {
                        "short": true
                        "title": "Docks Open"
                        "value": 3
                      }
                    ]
                    "title": "#2162 - Commerce & 2nd Ave N"
                    "ts": 1633141672
                  },
                  {
                    "author_icon": "https://github.com/bcycle.png"
                    "author_link": "https://nashville.bcycle.com/"
                    "author_name": "BCycle"
                    "color": "good"
                    "fallback": "#2165 - Church St between 4th & 5th Ave N > Active | Bikes: 1 | Docks: 8"
                    "fields": [
                      {
                        "short": false
                        "title": "Address"
                        "value": "<https://www.google.com/maps/place/36.16335,-86.77986|425 Church St.>"
                      }
                      {
                        "short": true
                        "title": "Bikes Available"
                        "value": 1
                      }
                      {
                        "short": true
                        "title": "Docks Open"
                        "value": 8
                      }
                    ]
                    "title": "#2165 - Church St between 4th & 5th Ave N"
                    "ts": 1633141672
                  }
                ]
              }
            ]
          ]
          done()
        catch err
          done err
        return
      , 1000)

  context 'regular tests', ->
    beforeEach ->
      process.env.BCYCLE_CITY = 'nashville'
      @room = helper.createRoom()

    afterEach ->
      @room.destroy()
      delete process.env.BCYCLE_CITY

    it 'returns error message if no default stations set', (done) ->
      selfRoom = @room
      selfRoom.user.say('alice', '@hubot bcycle')

      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle']
            ['hubot', 'You do not have any BCYCLE_DEFAULT_STATIONS configured.']
            ['hubot', 'Use `hubot bcycle search <query>` to find stations.']
          ]
          done()
        catch err
          done err
        return
      , 1000)

    # hubot bcycle list
    it 'gets a listing of stations in the city', (done) ->
      selfRoom = @room
      selfRoom.user.say('alice', '@hubot bcycle list')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle list']
            ['hubot', '#2162 - Commerce & 2nd Ave N']
            ['hubot', '#2165 - Church St between 4th & 5th Ave N']
            ['hubot', '#2166 - Public Square : 3rd Ave N & Union St']
            ['hubot', '#2168 - Cumberland Park']
            ['hubot', '#2169 - 6th Ave N & Union St']
            ['hubot', '#2170 - The Gulch : 11th Ave S & Pine St']
            ['hubot', '#2171 - Music Row Roundabout : 16th Ave S']
            ['hubot', '#2173 - 9th Ave S & Demonbreun St']
            ['hubot', '#2175 - Wedgewood Ave & 21st Ave S']
            ['hubot', '#2176 - 57 Peabody St']
            ['hubot', '#2177 - 5 Points East Nashville : S 11th St']
            ['hubot', '#2179 - Nashville Farmers\' Market']
            ['hubot', '#2180 - Germantown: 5th Ave & Monroe St']
            ['hubot', '#2181 - 3rd Ave S & Symphony Pl']
            ['hubot', '#2516 - 12th Ave S & Elmwood']
            ['hubot', '#2684 - Church St. and 20th Ave N']
            ['hubot', '#2973 - 2017 Belmont Blvd']
            ['hubot', '#2975 - Junior Gilliam Way & 5th Ave N']
            ['hubot', '#3456 - 40th Ave. N and Charlotte Ave.']
            ['hubot', '#3467 - Charlotte Ave and 46th Ave N']
            ['hubot', '#3568 - 200 21st Ave South']
            ['hubot', '#3613 - 715 Porter Road']
          ]
          done()
        catch err
          done err
        return
      , 1000)

    # hubot bcycle me <station id>
    it 'returns the status for a given station', (done) ->
      selfRoom = @room
      selfRoom.user.say('alice', '@hubot bcycle me 2162')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle me 2162']
            [
              'hubot',
              {
                "attachments": [
                  {
                    "author_icon": "https://github.com/bcycle.png"
                    "author_link": "https://nashville.bcycle.com/"
                    "author_name": "BCycle"
                    "color": "good"
                    "fallback": "#2162 - Commerce & 2nd Ave N > Active | Bikes: 12 | Docks: 3"
                    "fields": [
                      {
                        "short": false
                        "title": "Address"
                        "value": "<https://www.google.com/maps/place/36.16309,-86.77612|204 Commerce Ave.>"
                      }
                      {
                        "short": true
                        "title": "Bikes Available"
                        "value": 12
                      }
                      {
                        "short": true
                        "title": "Docks Open"
                        "value": 3
                      }
                    ]
                    "title": "#2162 - Commerce & 2nd Ave N"
                    "ts": 1633141672
                  }
                ]
              }
            ]
          ]
          done()
        catch err
          done err
        return
      , 1000)

    # hubot bcycle search <query>
    it 'searches the listing of stations', (done) ->
      selfRoom = @room
      selfRoom.user.say('alice', '@hubot bcycle search church st')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle search church st']
            ['hubot', '#2165 - Church St between 4th & 5th Ave N']
            ['hubot', '#2684 - Church St. and 20th Ave N']
          ]
          done()
        catch err
          done err
        return
      , 1000)

    # hubot bcycle info
    it 'returns information about your program', (done) ->
      selfRoom = @room
      selfRoom.user.say('alice', '@hubot bcycle info')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle info']
            [
              'hubot',
              {
                "attachments": [
                  {
                    "fallback": "Nashville BCycle | https://nashville.bcycle.com | 844-982-4533 | Nashville@bcycle.com",
                    "fields": [
                      {
                        "short": true,
                        "title": "Website",
                        "value": "<https://nashville.bcycle.com|https://nashville.bcycle.com>"
                      },
                      {
                        "short": true,
                        "title": "Phone Number",
                        "value": "844-982-4533"
                      },
                      {
                        "short": true,
                        "title": "Email",
                        "value": "<mailto:Nashville@bcycle.com|Nashville@bcycle.com>"
                      }
                    ]
                    "thumb_url": "https://github.com/bcycle.png",
                    "title": "Nashville BCycle",
                    "title_link": "https://nashville.bcycle.com/"
                  }
                ]
              }
            ]
          ]
          done()
        catch err
          done err
        return
      , 1000)

    # hubot bcycle price
    it 'returns pricing plan information', (done) ->
      selfRoom = @room
      selfRoom.user.say('alice', '@hubot bcycle price')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle price']
            [
              'hubot',
              {
                "attachments": [
                  {
                    "fallback": "Single Ride Pass Online ($5) - $5 per 30 minutes. Total minutes calculated and billed the following day.",
                    "text": "$5 per 30 minutes. Total minutes calculated and billed the following day.",
                    "title": "Single Ride Pass Online ($5)"
                  },
                  {
                    "fallback": "Guest Pass ($25) - Unlimited 120-minute rides in a 3-Day period. Additional rental fee of $3 per 30 minutes for rides longer than 120 minutes.",
                    "text": "Unlimited 120-minute rides in a 3-Day period. Additional rental fee of $3 per 30 minutes for rides longer than 120 minutes.",
                    "title": "Guest Pass ($25)"
                  },
                  {
                    "fallback": "Monthly Pass ($20) - Enjoy unlimited 60-minute rides for 30 days! Rides longer than 60 minutes are subject to a usage fee of $3 per additional 30 minutes.",
                    "text": "Enjoy unlimited 60-minute rides for 30 days! Rides longer than 60 minutes are subject to a usage fee of $3 per additional 30 minutes.",
                    "title": "Monthly Pass ($20)"
                  },
                  {
                    "fallback": "Annual Pass ($120) - Enjoy unlimited 120-minute rides for a year! *Limited time offer of 120-minutes.* Rides longer than 120 minutes are subject to a usage fee of $3 per additional 30 minutes.",
                    "text": "Enjoy unlimited 120-minute rides for a year! *Limited time offer of 120-minutes.* Rides longer than 120 minutes are subject to a usage fee of $3 per additional 30 minutes.",
                    "title": "Annual Pass ($120)"
                  },
                  {
                    "fallback": "Single Ride Pass  ($5) - $5 per 30 minutes. Total minutes calculated and billed the following day.",
                    "text": "$5 per 30 minutes. Total minutes calculated and billed the following day.",
                    "title": "Single Ride Pass  ($5)"
                  }
                ]
              }
            ]
          ]
          done()
        catch err
          done err
        return
      , 1000)

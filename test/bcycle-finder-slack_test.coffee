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
      process.env.BCYCLE_DEFAULT_STATIONS='2970,2974'
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
                    "fallback": "#2970 - Hill Center Trailhead: Richland Creek Greenway & N Kenner Ave > Active | Bikes: 4 | Docks: 7"
                    "fields": [
                      {
                        "short": false
                        "title": "Address"
                        "value": "<https://maps.google.com/?q=2%20Richland%20Creek%20Greenway%2C%20nashville|2 Richland Creek Greenway>"
                      }
                      {
                        "short": true
                        "title": "Bikes Available"
                        "value": 4
                      }
                      {
                        "short": true
                        "title": "Docks Open"
                        "value": 7
                      }
                    ]
                    "title": "#2970 - Hill Center Trailhead: Richland Creek Greenway & N Kenner Ave"
                    "ts": 1507606179
                  },
                  {
                    "author_icon": "https://github.com/bcycle.png"
                    "author_link": "https://nashville.bcycle.com/"
                    "author_name": "BCycle"
                    "color": "good"
                    "fallback": "#2974 - Shelby Bottoms Nature Center: 1900 Davidson St > Active | Bikes: 10 | Docks: 11"
                    "fields": [
                      {
                        "short": false
                        "title": "Address"
                        "value": "<https://maps.google.com/?q=1900%20Davidson%20Street%2C%20nashville|1900 Davidson Street>"
                      }
                      {
                        "short": true
                        "title": "Bikes Available"
                        "value": 10
                      }
                      {
                        "short": true
                        "title": "Docks Open"
                        "value": 11
                      }
                    ]
                    "title": "#2974 - Shelby Bottoms Nature Center: 1900 Davidson St"
                    "ts": 1507606179
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
            ['hubot', '#2162 - The District: Commerce & 2nd Ave N']
            ['hubot', '#2165 - Fifth Third Plaza: Church St between 4th & 5th Ave N']
            ['hubot', '#2166 - Public Square: 3rd Ave N & Union St']
            ['hubot', '#2167 - Riverfront Station: Broadway & 1st Ave N']
            ['hubot', '#2168 - Cumberland Park: Victory Way at Base of Pedestrian St Bridge']
            ['hubot', '#2169 - TPAC: 6th Ave N & Union St']
            ['hubot', '#2170 - The Gulch: 11th Ave S & Pine St']
            ['hubot', '#2171 - Music Row Roundabout: 16th Ave S']
            ['hubot', '#2172 - Centennial Park: 27th Ave N']
            ['hubot', '#2173 - Frist Center: 9th Ave S & Demonbreun St']
            ['hubot', '#2175 - Hillsboro Village: Wedgewood Ave & 21st Ave S']
            ['hubot', '#2176 - Trolley Barns: Peabody St']
            ['hubot', '#2177 - 5 Points East Nashville: S 11th St']
            ['hubot', '#2179 - Nashville Farmers\' Market: 7th Ave N / Outdoor Food Court']
            ['hubot', '#2180 - Germantown: NW 5th Ave & Monroe St']
            ['hubot', '#2181 - SoBro: 3rd Ave S & Symphony Pl']
            ['hubot', '#2315 - Downtown YMCA: Church St & 9th Ave N']
            ['hubot', '#2516 - 12 South Flats: 12th Ave S & Elmwood']
            ['hubot', '#2517 - Sevier Park: Kirkwood Ave & 12th Ave S']
            ['hubot', '#2684 - Saint Thomas Midtown: Church St. and 20th Ave N']
            ['hubot', '#2724 - McCabe Community Center: 103 46th Ave N']
            ['hubot', '#2970 - Hill Center Trailhead: Richland Creek Greenway & N Kenner Ave']
            ['hubot', '#2971 - Morgan Park: Magdeburg Greenway & 4th Ave N']
            ['hubot', '#2973 - Belmont Boulevard: 2101 Belmont Blvd']
            ['hubot', '#2974 - Shelby Bottoms Nature Center: 1900 Davidson St']
            ['hubot', '#2975 - First Tennessee Park: Junior Gilliam Way & 5th Ave N']
            ['hubot', '#3260 - Walk of Fame Park: 5th Ave S  & Demonbreun St.']
            ['hubot', '#3271 - J. Percy Priest Dam Trailhead: Stones River Greenway off Bell Rd']
            ['hubot', '#3315 - Two Rivers Skatepark: Two Rivers Greenway']
            ['hubot', '#3349 - Hadley Park Community Center: 1037 28th Ave North']
            ['hubot', '#3456 - 40th Ave. N and Charlotte Ave. ']
            ['hubot', '#3467 - Charlotte Ave and 46th Ave N ']
            ['hubot', '#3568 - 200 21st Ave South']
            ['hubot', '#3569 - Parthenon ']
            ['hubot', '#3597 - Ted Rhodes Golf Course: 1901 Ed Temple Blvd']
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
      selfRoom.user.say('alice', '@hubot bcycle me 2970')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle me 2970']
            [
              'hubot',
              {
                "attachments": [
                  {
                    "author_icon": "https://github.com/bcycle.png"
                    "author_link": "https://nashville.bcycle.com/"
                    "author_name": "BCycle"
                    "color": "good"
                    "fallback": "#2970 - Hill Center Trailhead: Richland Creek Greenway & N Kenner Ave > Active | Bikes: 4 | Docks: 7"
                    "fields": [
                      {
                        "short": false
                        "title": "Address"
                        "value": "<https://maps.google.com/?q=2%20Richland%20Creek%20Greenway%2C%20nashville|2 Richland Creek Greenway>"
                      }
                      {
                        "short": true
                        "title": "Bikes Available"
                        "value": 4
                      }
                      {
                        "short": true
                        "title": "Docks Open"
                        "value": 7
                      }
                    ]
                    "title": "#2970 - Hill Center Trailhead: Richland Creek Greenway & N Kenner Ave"
                    "ts": 1507606179
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
      selfRoom.user.say('alice', '@hubot bcycle search broadway')
      setTimeout(() ->
        try
          expect(selfRoom.messages).to.eql [
            ['alice', '@hubot bcycle search broadway']
            ['hubot', '#2167 - Riverfront Station: Broadway & 1st Ave N']
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
            ['hubot', 'Nashville BCycle | https://nashville.bcycle.com | (615) 625-2153 | emagas@nashvilledowntown.com']
          ]
          done()
        catch err
          done err
        return
      , 1000)

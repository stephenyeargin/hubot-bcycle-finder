# Description:
#   Get the status of nearby B-cycle stations
#
# Dependencies:
#   None
#
# Configuration:
#   BCYCLE_API_KEY - (string) API key provided at registration
#   BCYCLE_PROGRAM_ID - (int) The program (city) identifier
#   BCYCLE_DEFAULT_STATIONS - (string) Comma separated list of default stations
#
# Commands:
#   hubot bcycle - Returns the status of the default stations, if any
#   hubot bcycle list - Gets a listing of stations in the configured program
#   hubot bcycle me <station id> - Returns the status for a given station ID
#   hubot bcycle search <query> - Searches the listing of stations and returns matching names
#   hubot bcycle programs - Retrieves a list of Program IDs
#
# Author:
#   stephenyeargin

module.exports = (robot) ->
  api_url = 'https://publicapi.bcycle.com/api/1.0'
  api_key = process.env.BCYCLE_API_KEY
  program_id = process.env.BCYCLE_PROGRAM_ID
  default_stations = process.env.BCYCLE_DEFAULT_STATIONS

  ##
  # Returns the status of the default stations, if any
  robot.respond /bcycle$/i, (msg) ->
    return unless checkBCycleConfiguration msg

    if default_stations != ''
      default_stations = default_stations.toString().split(',')
    else
      default_stations = []

    # Check for default stations
    unless default_stations.length > 0
      msg.send "You do not have any default stations configured."
      msg.send "Use `#{robot.name} bcycle search <query>` to find stations."
      return

    response = makeBCycleRequest {
        method: 'ListProgramKiosks',
        id: program_id
      }, (err, res, body) ->
        # Handle error conditions
        return unless checkForError err, res, body, msg

        # Parse list of Stations
        stations = JSON.parse(body)

        # Print station data
        for station in stations
          continue unless station.Id.toString() in default_stations

          printStationData station, msg

  ##
  # Get a listing of stations in the configured program
  robot.respond /bcycle list$/i, (msg) ->
    return unless checkBCycleConfiguration msg

    response = makeBCycleRequest {
        method: 'ListProgramKiosks',
        id: program_id
      }, (err, res, body) ->
        # Handle error conditions
        return unless checkForError err, res, body, msg

        # Parse list of Stations
        stations = JSON.parse(body)

        # Print station data
        for station in stations
          if station.PublicText
            msg.send "##{station.Id} - #{station.Name} (#{station.PublicText})"
          else
            msg.send "##{station.Id} - #{station.Name}"

  ##
  # Returns the status for a given station ID
  robot.respond /bcycle me \#?([0-9]+)$/i, (msg) ->
    return unless checkBCycleConfiguration msg

    query = msg.match[1]

    response = makeBCycleRequest {
        method: 'ListProgramKiosks',
        id: program_id
      }, (err, res, body) ->
        # Handle error conditions
        return unless checkForError err, res, body, msg

        # Parse list of Stations
        stations = JSON.parse(body)

        # Print station data
        for station in stations
          continue if station.Id.toString() != query

          printStationData station, msg

  ##
  # Searches the listing of stations and returns status
  robot.respond /bcycle search (.*)$/i, (msg) ->
    return unless checkBCycleConfiguration msg

    query = msg.match[1].toLowerCase()
    station_matches = []

    response = makeBCycleRequest {
        method: 'ListProgramKiosks',
        id: program_id
      }, (err, res, body) ->
        return unless checkForError err, res, body, msg

        # Parse list of Stations
        stations = JSON.parse(body)

        # Find matches
        for station in stations
          if ~station.Name.toLowerCase().indexOf query
            station_matches.push station

        if station_matches.length == 0
          return msg.send "No stations matched your query: #{query}"

        # Print station data
        for station in station_matches
          if station.PublicText
            msg.send "##{station.Id} - #{station.Name} (#{station.PublicText})"
          else
            msg.send "##{station.Id} - #{station.Name}"

  ##
  # Get a list of programs
  robot.respond /bcycle programs$/i, (msg) ->

    response = makeBCycleRequest {
        method: 'ListPrograms',
        id: ''
      }, (err, res, body) ->
        return unless checkForError err, res, body, msg

        # Parse list of Stations
        programs = JSON.parse(body)

        for program in programs
          msg.send "#{program.ProgramId} - #{program.Name}"

  makeBCycleRequest = (options, callback) ->
    robot.http("#{api_url}/#{options.method}/#{options.id}")
      .header('ApiKey', api_key)
      .get() (err, res, body) ->
        callback(err, res, body)

  checkForError = (err, res, body, msg) ->
      unless res.statusCode == 200
        msg.send "#{res.statusCode}: #{body}"
        return false
      true

  printStationData = (station, msg) ->
    if station.PublicText
      msg.send "##{station.Id} - #{station.Name} (#{station.PublicText})"
    else
      msg.send "##{station.Id} - #{station.Name}"
    msg.send "> #{station.Status}: Bikes: #{station.BikesAvailable} | Docks: #{station.DocksAvailable} | Total: #{station.TotalDocks}"

  checkBCycleConfiguration = (msg) ->
    unless api_key && program_id
      msg.send "You are missing the BCYCLE_API_KEY and/or BCYCLE_PROGRAM_ID configuration variables."
      return false
    true

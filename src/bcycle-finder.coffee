# Description:
#   Get the status of nearby BCycle stations
#
# Dependencies:
#   None
#
# Configuration:
#   BCYCLE_CITY - name of the BCycle city, defaults to Madison
#   BCYCLE_DEFAULT_STATIONS - (optional) comma separated list of station IDs
#
# Commands:
#   hubot bcycle - Returns the status of the default stations, if any
#   hubot bcycle list - Gets a listing of stations in the configured program
#   hubot bcycle me <station id> - Returns the status for a given station ID
#   hubot bcycle search <query> - Searches the listing of stations
#
# Author:
#   stephenyeargin

_ = require 'lodash'

module.exports = (robot) ->
  config =
    api_url: 'https://gbfs.bcycle.com'
    city: process.env.BCYCLE_CITY || 'madison'
    default_stations: process.env.BCYCLE_DEFAULT_STATIONS

  ##
  # Returns the status of the default stations, if any
  robot.respond /bcycle$/i, (msg) ->
    # Process default stations
    if config.default_stations != ''
      default_stations = config.default_stations.toString().split(',')
    else
      default_stations = []

    # Check for default stations
    unless default_stations.length > 0
      msg.send "You do not have any default stations configured."
      msg.send "Use `#{robot.name} bcycle search <query>` to find stations."
      return

    # Get list of stations
    makeBCycleRequest 'station_information', (err, res, body) ->
      # Handle error conditions
      return unless checkForError err, res, body, msg

      # Parse list of stations
      apiResponseInformation = JSON.parse(body)

      # Get station status
      makeBCycleRequest 'station_status', (err, res, body) ->
        # Handle error conditions
        return unless checkForError err, res, body, msg

        # Parse station statuses
        apiResponseStatus = JSON.parse(body)

        # Merge the lists
        mergedList = _(apiResponseInformation.data.stations)
          .concat(apiResponseStatus.data.stations)
          .groupBy('station_id')
          .map(_.spread(_.assign))
          .value()

        # Print station data
        for station in mergedList
          continue unless formatStationId(station) in default_stations
          printStationStatus station, msg

  ##
  # Get a listing of stations in the configured program
  robot.respond /bcycle list$/i, (msg) ->
    makeBCycleRequest 'station_information', (err, res, body) ->
      # Handle error conditions
      return unless checkForError err, res, body, msg

      # Parse list of Stations
      apiResponse = JSON.parse(body)

      # Print station data
      for station in apiResponse.data.stations
        msg.send formatStationName station

  ##
  # Returns the status for a given station ID
  robot.respond /bcycle me \#?([0-9]+)$/i, (msg) ->
    query = msg.match[1]

    makeBCycleRequest 'station_information', (err, res, body) ->
      # Handle error conditions
      return unless checkForError err, res, body, msg

      # Parse list of Stations
      apiResponseInformation = JSON.parse(body)

      # Get station status
      makeBCycleRequest 'station_status', (err, res, body) ->
        # Handle error conditions
        return unless checkForError err, res, body, msg

        # Parse station statuses
        apiResponseStatus = JSON.parse(body)

        # Merge the lists
        mergedList = _(apiResponseInformation.data.stations)
          .concat(apiResponseStatus.data.stations)
          .groupBy('station_id')
          .map(_.spread(_.assign))
          .value()

        # Print station data
        for station in mergedList
          continue if formatStationId(station) != query
          printStationStatus station, msg

  ##
  # Searches the listing of stations and returns status
  robot.respond /bcycle search (.*)$/i, (msg) ->
    query = msg.match[1].toLowerCase()
    station_matches = []

    makeBCycleRequest 'station_information', (err, res, body) ->
      return unless checkForError err, res, body, msg

      # Parse list of Stations
      apiResponse = JSON.parse(body)

      # Find matches
      for station in apiResponse.data.stations
        if ~station.name.toLowerCase().indexOf query
          station_matches.push station

      # No matches
      if station_matches.length == 0
        return msg.send "No stations matched your query: #{query}"

      # Print station data
      for station in station_matches
        msg.send formatStationName station

  ##
  # Make BCycle Request
  makeBCycleRequest = (feed, callback) ->
    robot.http("#{config.api_url}/bcycle_#{config.city}/#{feed}.json")
      .get() (err, res, body) ->
        callback(err, res, body)

  ##
  # Check for Error
  checkForError = (err, res, body, msg) ->
    if err
      msg.send err.message
      return false
    if res.statusCode != 200
      msg.send "#{res.statusCode}: #{body}"
      return false
    true

  ##
  # Print Station Status
  printStationStatus = (station, msg) ->
    msg.send formatStationName station
    status = if station.is_renting == 1 then 'Active' else 'Inactive'
    msg.send "> #{status} | Bikes: #{station.num_bikes_available} | Docks: #{station.num_docks_available}"

  ##
  # Format Station ID
  formatStationId = (station) ->
    return station.station_id.replace("bcycle_#{config.city}_", '')

  ##
  # Format Station Name
  formatStationName = (station) ->
    return "##{formatStationId(station)} - #{station.name}"

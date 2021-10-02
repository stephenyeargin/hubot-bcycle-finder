# Description
#   Get the status of nearby BCycle stations
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
#   hubot bcycle info - Contact information for your program
#   hubot bcycle price - List the available pricing plans
#
# Author:
#   stephenyeargin

_ = require 'lodash'

module.exports = (robot) ->
  config =
    api_url: 'https://gbfs.bcycle.com'
    city: process.env.BCYCLE_CITY || 'madison'
    default_stations: process.env.BCYCLE_DEFAULT_STATIONS || ''

  ##
  # Returns the status of the default stations, if any
  robot.respond /bcycle$/i, (msg) ->
    # Process default stations
    if config.default_stations != ''
      default_stations = config.default_stations.split(',')
    else
      default_stations = []

    # Check for default stations
    unless default_stations.length > 0
      msg.send "You do not have any BCYCLE_DEFAULT_STATIONS configured."
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

        # Return station data
        output = _.chain(mergedList)
          .filter( (station) ->
            return formatStationId(station) in default_stations
          )
          .map( (station) ->
            return formatStationStatus(station)
          )
          .value()

        # Send output
        sendMessage output, msg

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

        output = _.chain(mergedList)
          .filter( (station) ->
            return formatStationId(station) == query
          )
          .map( (station) ->
            return formatStationStatus(station)
          )
          .value()

        # Send output
        sendMessage output, msg

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
  # Returns contact information for program
  robot.respond /bcycle info$/i, (msg) ->
    makeBCycleRequest 'system_information', (err, res, body) ->
      return unless checkForError err, res, body, msg

      # Parse system information
      response = JSON.parse(body)

      switch robot.adapterName
        when 'slack'
          msg.send {
            attachments: [
              {
                fallback: "#{response.data.name} | #{response.data.url} | #{response.data.phone_number} | #{response.data.email}",
                title: response.data.name,
                title_link: "https://#{config.city}.bcycle.com/",
                thumb_url: "https://github.com/bcycle.png",
                fields: [
                  {
                    title: "Website",
                    value: "<#{response.data.url}|#{response.data.url}>",
                    short: true
                  },
                  {
                    title: "Phone Number",
                    value: response.data.phone_number,
                    short: true
                  },
                  {
                    title: "Email",
                    value: "<mailto:#{response.data.email}|#{response.data.email}>",
                    short: true
                  }
                ]
              }
            ]
          }
        else
          msg.send "#{response.data.name} | #{response.data.url} | #{response.data.phone_number} | #{response.data.email}"

  ##
  # Show Pricing Plans for Program
  robot.respond /bcycle (price|prices|pricing|plan|plans)$/i, (msg) ->
    makeBCycleRequest 'system_pricing_plans', (err, res, body) ->
      return unless checkForError err, res, body, msg
      response = JSON.parse(body)

      output = []
      for plan in response.data.plans
        output.push(formatPricingPlan plan)

      sendMessage output, msg

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
  formatStationStatus = (station) ->
    status = if station.is_renting == 1 then 'Active' else 'Inactive'
    stationName = formatStationName station
    stationColor = if station.is_renting == 1 then 'good' else 'danger'
    stationMapLink = "https://www.google.com/maps/place/#{station.lat},#{station.lon}"

    switch robot.adapterName
      when 'slack'
        payload = {
          fallback: "#{stationName} > #{status} | Bikes: #{station.num_bikes_available} | Docks: #{station.num_docks_available}",
          title: stationName,
          color: stationColor,
          author_name: 'BCycle',
          author_link: "https://#{config.city}.bcycle.com/",
          author_icon: "https://github.com/bcycle.png",
          fields: [
            {
              title: "Address",
              value: "<#{stationMapLink}|#{station.address}>",
              short: false
            }
            {
              title: "Bikes Available",
              value: station.num_bikes_available,
              short: true
            },
            {
              title: "Docks Open",
              value: station.num_docks_available,
              short: true
            }
          ],
          ts: station.last_reported
        }
      else
        payload = "#{stationName}\n> #{status} | Bikes: #{station.num_bikes_available} | Docks: #{station.num_docks_available}"
    # Return payload
    return payload

  ##
  # Format Station ID
  formatStationId = (station) ->
    return station.station_id.replace("bcycle_#{config.city}_", '')

  ##
  # Format Station Name
  formatStationName = (station) ->
    return "##{formatStationId(station)} - #{station.name.trim()}"

  ##
  # Format Pricing Plan
  formatPricingPlan = (plan) ->
    switch robot.adapterName
      when 'slack'
        payload = {
          fallback: "#{plan.name} ($#{plan.price}) - #{plan.description}"
          title: "#{plan.name} ($#{plan.price})"
          text: plan.description
        }
      else
        payload = "#{plan.name} ($#{plan.price}) - #{plan.description}"
    # Return payload
    return payload

  ##
  # Send message
  sendMessage = (payload, msg) ->
    switch robot.adapterName
      when 'slack'
        msg.send {
          attachments: payload
        }
      else
        msg.send payload.join("\n")

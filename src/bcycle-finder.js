// Description:
//   Get the status of nearby BCycle stations
//
// Configuration:
//   BCYCLE_CITY - name of the BCycle city, defaults to Madison
//   BCYCLE_DEFAULT_STATIONS - (optional) comma separated list of station IDs
//
// Commands:
//   hubot bcycle - Returns the status of the default stations, if any
//   hubot bcycle list - Gets a listing of stations in the configured program
//   hubot bcycle me <station id> - Returns the status for a given station ID
//   hubot bcycle search <query> - Searches the listing of stations
//   hubot bcycle info - Contact information for your program
//   hubot bcycle price - List the available pricing plans
//
// Author:
//   stephenyeargin

const _ = require('lodash');

module.exports = (robot) => {
  const config = {
    api_url: 'https://gbfs.bcycle.com',
    city: process.env.BCYCLE_CITY,
    defaultStations: process.env.BCYCLE_DEFAULT_STATIONS || '',
  };

  // Make BCycle Request
  const makeBCycleRequest = (feed, callback) => robot.http(`${config.api_url}/bcycle_${config.city}/${feed}.json`)
    .get()((err, res, body) => callback(err, res, body));

  // Check Configuration
  const checkConfiguration = (msg) => {
    if (!config.city) {
      msg.send('You must configure BCYCLE_CITY before use.');
      return false;
    }
    return true;
  };

  // Check for Error
  const checkForError = (err, res, body, msg) => {
    if (err) {
      msg.send(err.message);
      return false;
    }
    if (res.statusCode !== 200) {
      msg.send(`${res.statusCode}: ${body}`);
      return false;
    }
    return true;
  };

  // Format Station ID
  const formatStationId = (station) => station.station_id.replace(`bcycle_${config.city}_`, '');

  // Format Station Name
  const formatStationName = (station) => `#${formatStationId(station)} - ${station.name.trim()}`;

  // Print Station Status
  const formatStationStatus = (station) => {
    let payload;
    const status = station.is_renting === 1 ? 'Active' : 'Inactive';
    const stationName = formatStationName(station);
    const stationColor = station.is_renting === 1 ? 'good' : 'danger';
    const stationMapLink = `https://www.google.com/maps/place/${station.lat},${station.lon}`;

    switch (robot.adapterName) {
      case 'slack':
        payload = {
          fallback: `${stationName} > ${status} | Bikes: ${station.num_bikes_available} | Docks: ${station.num_docks_available}`,
          title: stationName,
          color: stationColor,
          author_name: 'BCycle',
          author_link: `https://${config.city}.bcycle.com/`,
          author_icon: 'https://github.com/bcycle.png',
          fields: [
            {
              title: 'Address',
              value: `<${stationMapLink}|${station.address}>`,
              short: false,
            },
            {
              title: 'Bikes Available',
              value: station.num_bikes_available,
              short: true,
            },
            {
              title: 'Docks Open',
              value: station.num_docks_available,
              short: true,
            },
          ],
          ts: station.last_reported,
        };
        break;
      default:
        payload = `${stationName}\n> ${status} | Bikes: ${station.num_bikes_available} | Docks: ${station.num_docks_available}`;
    }
    // Return payload
    return payload;
  };

  // Format Pricing Plan
  const formatPricingPlan = (plan) => {
    let payload;
    switch (robot.adapterName) {
      case 'slack':
        payload = {
          fallback: `${plan.name} ($${plan.price}) - ${plan.description}`,
          title: `${plan.name} ($${plan.price})`,
          text: plan.description,
        };
        break;
      default:
        payload = `${plan.name} ($${plan.price}) - ${plan.description}`;
    }
    // Return payload
    return payload;
  };

  // Send message
  const sendMessage = (payload, msg) => {
    switch (robot.adapterName) {
      case 'slack':
        return msg.send({
          attachments: payload,
        });
      default:
        return msg.send(payload.join('\n'));
    }
  };

  // Returns the status of the default stations, if any
  robot.respond(/bcycle$/i, (msg) => {
    let defaultStations;
    if (!checkConfiguration(msg)) { return; }

    // Process default stations
    if (config.defaultStations !== '') {
      defaultStations = config.defaultStations.split(',');
    } else {
      defaultStations = [];
    }

    // Check for default stations
    if (!(defaultStations.length > 0)) {
      msg.send('You do not have any BCYCLE_DEFAULT_STATIONS configured.');
      msg.send(`Use \`${robot.name} bcycle search <query>\` to find stations.`);
      return;
    }

    // Get list of stations
    makeBCycleRequest('station_information', (err, res, body) => {
      // Handle error conditions
      if (!checkForError(err, res, body, msg)) { return; }

      // Parse list of stations
      const apiResponseInformation = JSON.parse(body);

      // Get station status
      makeBCycleRequest('station_status', (err2, res2, body2) => {
        // Handle error conditions
        if (!checkForError(err2, res2, body2, msg)) { return; }

        // Parse station statuses
        const apiResponseStatus = JSON.parse(body2);

        // Merge the lists
        const mergedList = _(apiResponseInformation.data.stations)
          .concat(apiResponseStatus.data.stations)
          .groupBy('station_id')
          .map(_.spread(_.assign))
          .value();

        // Return station data
        const output = _.chain(mergedList)
          .filter((station) => {
            const needle = formatStationId(station);
            return defaultStations.includes(needle);
          })
          .map((station) => formatStationStatus(station))
          .value();

        // Send output
        sendMessage(output, msg);
      });
    });
  });

  // Get a listing of stations in the configured program
  robot.respond(/bcycle (?:list|stations)$/i, (msg) => {
    if (!checkConfiguration(msg)) { return; }

    makeBCycleRequest('station_information', (err, res, body) => {
      // Handle error conditions
      if (!checkForError(err, res, body, msg)) { return; }

      // Parse list of Stations
      const apiResponse = JSON.parse(body);

      // Print station data
      apiResponse.data.stations.map((station) => msg.send(formatStationName(station)));
    });
  });

  // Returns the status for a given station ID
  robot.respond(/bcycle (?:me|station) #?([0-9]+)$/i, (msg) => {
    if (!checkConfiguration(msg)) { return; }

    const query = msg.match[1];

    makeBCycleRequest('station_information', (err, res, body) => {
      // Handle error conditions
      if (!checkForError(err, res, body, msg)) { return; }

      // Parse list of Stations
      const apiResponseInformation = JSON.parse(body);

      // Get station status
      makeBCycleRequest('station_status', (err2, res2, body2) => {
        // Handle error conditions
        if (!checkForError(err2, res2, body2, msg)) { return; }

        // Parse station statuses
        const apiResponseStatus = JSON.parse(body2);

        // Merge the lists
        const mergedList = _(apiResponseInformation.data.stations)
          .concat(apiResponseStatus.data.stations)
          .groupBy('station_id')
          .map(_.spread(_.assign))
          .value();

        const output = _.chain(mergedList)
          .filter((station) => formatStationId(station) === query)
          .map((station) => formatStationStatus(station))
          .value();

        // Send output
        sendMessage(output, msg);
      });
    });
  });

  // Searches the listing of stations and returns status
  robot.respond(/bcycle search (.*)$/i, (msg) => {
    if (!checkConfiguration(msg)) { return; }

    const query = msg.match[1].toLowerCase();

    makeBCycleRequest('station_information', (err, res, body) => {
      if (!checkForError(err, res, body, msg)) { return; }

      // Parse list of Stations
      const apiResponse = JSON.parse(body);

      // Find matches
      const stationMatches = apiResponse.data.stations.filter((station) => {
        if (station.name.toLowerCase().indexOf(query) > -1) {
          return true;
        }
        return false;
      });

      // No matches
      if (stationMatches.length === 0) {
        msg.send(`No stations matched your query: ${query}`);
      }

      // Print station data
      stationMatches.map((station) => msg.send(formatStationName(station)));
    });
  });

  // Returns contact information for program
  robot.respond(/bcycle info$/i, (msg) => {
    if (!checkConfiguration(msg)) { return; }

    makeBCycleRequest('system_information', (err, res, body) => {
      if (!checkForError(err, res, body, msg)) { return; }

      // Parse system information
      const response = JSON.parse(body);

      switch (robot.adapterName) {
        case 'slack':
          msg.send({
            attachments: [
              {
                fallback: `${response.data.name} | ${response.data.url} | ${response.data.phone_number} | ${response.data.email}`,
                title: response.data.name,
                title_link: `https://${config.city}.bcycle.com/`,
                thumb_url: 'https://github.com/bcycle.png',
                fields: [
                  {
                    title: 'Website',
                    value: `<${response.data.url}|${response.data.url}>`,
                    short: true,
                  },
                  {
                    title: 'Phone Number',
                    value: response.data.phone_number,
                    short: true,
                  },
                  {
                    title: 'Email',
                    value: `<mailto:${response.data.email}|${response.data.email}>`,
                    short: true,
                  },
                ],
              },
            ],
          });
          break;
        default:
          msg.send(`${response.data.name} | ${response.data.url} | ${response.data.phone_number} | ${response.data.email}`);
      }
    });
  });

  // Show Pricing Plans for Program
  robot.respond(/bcycle (?:price|prices|pricing|plan|plans)$/i, (msg) => {
    if (!checkConfiguration(msg)) { return; }

    makeBCycleRequest('system_pricing_plans', (err, res, body) => {
      if (!checkForError(err, res, body, msg)) { return; }
      const response = JSON.parse(body);
      const output = [];
      response.data.plans.forEach((plan) => {
        output.push(formatPricingPlan(plan));
      });
      sendMessage(output, msg);
    });
  });
};

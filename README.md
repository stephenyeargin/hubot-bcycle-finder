# Hubot BCycle Finder

[![npm version](https://badge.fury.io/js/hubot-bcycle-finder.svg)](http://badge.fury.io/js/hubot-bcycle-finder) [![Build Status](https://app.travis-ci.com/stephenyeargin/hubot-bcycle-finder.png)](https://app.travis-ci.com/stephenyeargin/hubot-bcycle-finder)

Get the status of nearby BCycle stations.

## Installation

In your hubot repository, run:

`npm install hubot-bcycle-finder --save`

Then add **hubot-bcycle-finder** to your `external-scripts.json`:

```json
["hubot-bcycle-finder"]
```

### Configuration

| Environment Variables | Required? | Description                              |
| --------------------- | :-------: | ---------------------------------------- |
| `BCYCLE_CITY`         | Yes       | Lowercase, city code for BCycle program  |
| `BCYCLE_DEFAULT_STATIONS` | Yes   | Comma separated list of stations         |

NOTE: You can retrieve the station IDs by using `hubot bcycle search <query>` 

## Usage

### Default stations

Returns the status of the default stations, if any.

```
user> hubot bcycle
hubot> #2171 - Music Row Roundabout: 16th Ave S (B card only)
hubot> > Active | Bikes: 8 | Docks: 3 | Total: 11
hubot> #2173 - Frist Center: 9th Ave S & Demonbreun St
hubot> > Active | Bikes: 6 | Docks: 5 | Total: 11
```

### List stations

_Note: This will likely flood your chat room. Consider using `hubot bcycle search` instead._

```
user> hubot bcycle list
hubot> #2162 - The District: Commerce & 2nd Ave N
hubot> #2164 - North Capitol: 4th Ave N & James Robertson Pkwy
hubot> #2165 - Fifth Third Plaza: Church St between 4th & 5th Ave N
hubot> #2166 - Public Square: 3rd Ave N & Union St
hubot> #2168 - Cumberland Park: Victory Way at Base of Pedestrian St Bridge
hubot> #2169 - TPAC: 6th Ave N & Union St
hubot> #2170 - The Gulch: 11th Ave S & 12th Ave S
hubot> #2171 - Music Row Roundabout: 16th Ave S (B card only)
hubot> #2172 - Centennial Park: 27th Ave N
hubot> #2173 - Frist Center: 9th Ave S & Demonbreun St
hubot> #2174 - Fisk/Meharry: Jefferson St & Dr. D.B. Todd Blvd
hubot> #2175 - Hillsboro Village: Wedgewood Ave & 21st Ave S
hubot> #2176 - Rolling Mill Hill: Hermitage Ave & Middleton St
hubot> #2177 - 5 Points East Nashville: S 11th St
[...]
```

### Get status of a station

```
user> hubot bcycle me 2162
hubot> #2162 - The District: Commerce & 2nd Ave N
hubot> > Active: Bikes: 7 | Docks: 4 | Total: 11
```

### Search station names

```
user> hubot bcycle search cumberland
hubot> #2168 - Cumberland Park: Victory Way at Base of Pedestrian St Bridge
```

### Get program information

```
user> hubot bcycle info
hubot> Nashville BCycle | https://nashville.bcycle.com | (615) 625-2153 | emagas@nashvilledowntown.com
```

### Get pricing plans

```
user> hubot bcycle price
hubot> Single Ride Pass Online ($5) - $5 per 30 minutes. Total minutes calculated and billed the following day.
Guest Pass ($25) - Unlimited 120-minute rides in a 3-Day period. Additional rental fee of $3 per 30 minutes for rides longer than 120 minutes.
Monthly Pass ($20) - Enjoy unlimited 60-minute rides for 30 days! Rides longer than 60 minutes are subject to a usage fee of $3 per additional 30 minutes.
Annual Pass ($120) - Enjoy unlimited 120-minute rides for a year! *Limited time offer of 120-minutes.* Rides longer than 120 minutes are subject to a usage fee of $3 per additional 30 minutes.
Single Ride Pass  ($5) - $5 per 30 minutes. Total minutes calculated and billed the following day.
```

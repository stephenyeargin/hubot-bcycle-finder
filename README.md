# Hubot BCycle Finder

[![npm version](https://badge.fury.io/js/hubot-bcycle-finder.svg)](http://badge.fury.io/js/hubot-bcycle-finder) [![Build Status](https://travis-ci.org/stephenyeargin/hubot-bcycle-finder.png)](https://travis-ci.org/stephenyeargin/hubot-bcycle-finder)

Get the status of nearby BCycle stations

## Installation

In your hubot repository, run:

`npm install hubot-bcycle-finder --save`

Then add **hubot-bcycle-finder** to your `external-scripts.json`:

```json
["hubot-bcycle-finder"]
```

### Configuration

The script has two environment variables.

- `BCYCLE_CITY` is the name of the BCycle city.
- `BCYCLE_DEFAULT_STATIONS` is a comma separated list of integers of your preferred stations
 - You can retrieve the station IDs by using `hubot bcycle search <some query>` 

### Heroku

```bash
heroku config:set BCYCLE_CITY=nashville
heroku config:set BCYCLE_DEFAULT_STATIONS=2171,2173
```

### Standard

```
export BCYCLE_CITY=nashville
export BCYCLE_DEFAULT_STATIONS=2171,2173
```

## Usage

### `hubot bcycle`

Returns the status of the default stations, if any.

```
user> hubot bcycle
hubot> #2171 - Music Row Roundabout: 16th Ave S (B card only)
hubot> > Active | Bikes: 8 | Docks: 3 | Total: 11
hubot> #2173 - Frist Center: 9th Ave S & Demonbreun St
hubot> > Active | Bikes: 6 | Docks: 5 | Total: 11
```

### `hubot bcycle list`

Get a listing of stations in the configured program. _Note: This will likely flood your chat room. Consider using `hubot bcycle search` instead._

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

### `hubot bcycle me <station id>`

Returns the status for a given station ID.

```
user> hubot bcycle me 2162
hubot> #2162 - The District: Commerce & 2nd Ave N
hubot> > Active: Bikes: 7 | Docks: 4 | Total: 11
```

### `hubot bcycle search <query>`

Searches the listing of stations and returns matching names.

```
user> hubot bcycle search cumberland
hubot> #2168 - Cumberland Park: Victory Way at Base of Pedestrian St Bridge
```

### `hubot bcycle info`

Returns information about your city's program.

```
user> hubot bcycle info
hubot> Nashville BCycle | https://nashville.bcycle.com | (615) 625-2153 | emagas@nashvilledowntown.com
```

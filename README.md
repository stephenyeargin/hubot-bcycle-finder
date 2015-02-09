# Hubot B-cycle Finder

Get the status of nearby B-cycle stations

[![Build Status](https://travis-ci.org/stephenyeargin/hubot-bcycle-finder.png)](https://travis-ci.org/stephenyeargin/hubot-bcycle-finder)

## Getting Started

The first step is to apply for a B-cycle API key. You will need to sign an agreement with B-cycle to use the API. To get started, use the website's [contact form](https://www.bcycle.com/contact-us). They are really nice over there.

You will receive an API key as well as a PDF document outlining how to use the API as soon as you've returned the agreement.

## Installation

In your hubot repository, run:

`npm install hubot-bcycle-finder --save`

Then add **hubot-bcycle-finder** to your `external-scripts.json`:

```json
["hubot-bcycle-finder"]
```

### Configuration

The script has tree environment variables.

- `BCYCLE_API_KEY` is the one provided at registration
- `BCYCLE_PROGRAM_ID` is an integer that corresponds with your city.
 - You can retrieve an up-to-date program list by using `hubot bcycle programs`
- `BCYCLE_DEFAULT_STATIONS` is a comma separated list of integers of your preferred stations
 - You can retrieve the station IDs by using `hubot bcycle search <some query>` 

### Heroku

```bash
heroku config:set BCYCLE_API_KEY=YOUR-API-KEYHERE
heroku config:set BCYCLE_PROGRAM_ID=64
heroku config:set BCYCLE_DEFAULT_STATIONS=2171,2173
```

### Standard

```
export BCYCLE_API_KEY=YOUR-API-KEYHERE
export BCYCLE_PROGRAM_ID=64
export BCYCLE_DEFAULT_STATIONS=2171,2173
```

## Usage

### `hubot bcycle`

Returns the status of the default stations, if any.

```
user> hubot bcycle
hubot> #2171 - Music Row Roundabout: 16th Ave S (B card only)
hubot> > Active: Bikes: 8 | Docks: 3 | Total: 11
hubot> #2173 - Frist Center: 9th Ave S & Demonbreun St
hubot> > Active: Bikes: 6 | Docks: 5 | Total: 11
```

### `hubot bcycle list`

Get a listing of stations in the configured program. _Note: This will likely flood your chat room. Consider using `hubot bcycle search` instead._

```
user> hubot bcycle list
hubot> #2162 - The District: Commerce & 2nd Ave N
hubot> #2164 - North Capitol: 4th Ave N & James Robertson Pkwy (Check outs By B-card only)
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

### `hubot bcycle programs`

Retrieves a list of Program IDs.

```
user> hubot bcycle programs
hubot> 76 - ArborBike
hubot> 72 - Austin B-cycle
hubot> 71 - Battle Creek B-cycle
hubot> 68 - Bikesantiago
hubot> 54 - Boulder B-cycle
hubot> 53 - Broward B-cycle
hubot> 70 - Bublr Bikes
hubot> 61 - Charlotte B-cycle
hubot> 80 - Cincy Red Bike
hubot> 74 - Columbia County B-cycle
hubot> 82 - Dallas Fair Park
hubot> 36 - Denver Bike Sharing
hubot> 45 - Des Moines B-cycle
hubot> 60 - DFC B-cycle
hubot> 67 - Fort Worth Bike Sharing
hubot> 81 - Great Rides Bike Share
hubot> 66 - GREENbike
hubot> 65 - Greenville B-cycle
hubot> 47 - gRide
hubot> 49 - Hawaii B-cycle
hubot> 56 - Heartland B-cycle
hubot> 59 - Houston B-cycle
hubot> 75 - Indy - Pacers Bikeshare 
hubot> 62 - Kansas City B-cycle
hubot> 55 - Madison B-cycle
hubot> 64 - Nashville B-cycle
hubot> 79 - Rapid City B-cycle
hubot> 48 - San Antonio B-cycle
hubot> 73 - Savannah
hubot> 57 - Spartanburg B-cycle
hubot> 77 - Whippany NJ
```

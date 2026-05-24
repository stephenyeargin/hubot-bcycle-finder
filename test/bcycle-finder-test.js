const {
  describe, it, before, after, beforeEach, afterEach,
} = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');
const nock = require('nock');
const { createTestBot } = require('./common/TestBot');

const fixturesDir = path.resolve(__dirname, 'fixtures');

function setupNocks() {
  nock('https://gbfs.bcycle.com')
    .get('/bcycle_nashville/system_information.json')
    .replyWithFile(200, `${fixturesDir}/system_information.json`);
  nock('https://gbfs.bcycle.com')
    .get('/bcycle_nashville/system_pricing_plans.json')
    .replyWithFile(200, `${fixturesDir}/system_pricing_plans.json`);
  nock('https://gbfs.bcycle.com')
    .get('/bcycle_nashville/station_information.json')
    .replyWithFile(200, `${fixturesDir}/station_information.json`);
  nock('https://gbfs.bcycle.com')
    .get('/bcycle_nashville/station_status.json')
    .replyWithFile(200, `${fixturesDir}/station_status.json`);
}

describe('hubot-bcycle-finder', () => {
  describe('default stations tests', () => {
    let bot;

    before(async () => {
      bot = await createTestBot({ BCYCLE_CITY: 'nashville', BCYCLE_DEFAULT_STATIONS: '2162,2165' });
    });

    after(() => bot.shutdown());

    beforeEach(() => setupNocks());
    afterEach(() => nock.cleanAll());

    it('returns the status of the default stations', async () => {
      const response = await bot.sendAndWaitForResponse('@hubot bcycle');
      assert.equal(response, '#2162 - Commerce & 2nd Ave N\n> Active | Bikes: 12 | Docks: 3\n#2165 - Church St between 4th & 5th Ave N\n> Active | Bikes: 1 | Docks: 8');
    });
  });

  describe('regular tests', () => {
    let bot;

    before(async () => {
      bot = await createTestBot({ BCYCLE_CITY: 'nashville', BCYCLE_DEFAULT_STATIONS: null });
    });

    after(() => bot.shutdown());

    beforeEach(() => setupNocks());
    afterEach(() => nock.cleanAll());

    it('returns error message if no default stations set', async () => {
      await bot.send('@hubot bcycle');
      assert.equal(bot.sends[bot.sends.length - 2], 'You do not have any BCYCLE_DEFAULT_STATIONS configured.');
      assert.equal(bot.sends[bot.sends.length - 1], 'Use `hubot bcycle search <query>` to find stations.');
    });

    it('gets a listing of stations in the city', async () => {
      const sendsBefore = bot.sends.length;
      await bot.send('@hubot bcycle list');
      const newSends = bot.sends.slice(sendsBefore);
      assert.deepEqual(newSends, [
        '#2162 - Commerce & 2nd Ave N',
        '#2165 - Church St between 4th & 5th Ave N',
        '#2166 - Public Square : 3rd Ave N & Union St',
        '#2168 - Cumberland Park',
        '#2169 - 6th Ave N & Union St',
        '#2170 - The Gulch : 11th Ave S & Pine St',
        '#2171 - Music Row Roundabout : 16th Ave S',
        '#2173 - 9th Ave S & Demonbreun St',
        '#2175 - Wedgewood Ave & 21st Ave S',
        '#2176 - 57 Peabody St',
        '#2177 - 5 Points East Nashville : S 11th St',
        "#2179 - Nashville Farmers' Market",
        '#2180 - Germantown: 5th Ave & Monroe St',
        '#2181 - 3rd Ave S & Symphony Pl',
        '#2516 - 12th Ave S & Elmwood',
        '#2684 - Church St. and 20th Ave N',
        '#2973 - 2017 Belmont Blvd',
        '#2975 - Junior Gilliam Way & 5th Ave N',
        '#3456 - 40th Ave. N and Charlotte Ave.',
        '#3467 - Charlotte Ave and 46th Ave N',
        '#3568 - 200 21st Ave South',
        '#3613 - 715 Porter Road',
      ]);
    });

    it('returns the status for a given station', async () => {
      const response = await bot.sendAndWaitForResponse('@hubot bcycle me 2162');
      assert.equal(response, '#2162 - Commerce & 2nd Ave N\n> Active | Bikes: 12 | Docks: 3');
    });

    it('searches the listing of stations', async () => {
      const sendsBefore = bot.sends.length;
      await bot.send('@hubot bcycle search church st');
      const newSends = bot.sends.slice(sendsBefore);
      assert.deepEqual(newSends, [
        '#2165 - Church St between 4th & 5th Ave N',
        '#2684 - Church St. and 20th Ave N',
      ]);
    });

    it('returns information about your program', async () => {
      const response = await bot.sendAndWaitForResponse('@hubot bcycle info');
      assert.equal(response, 'Nashville BCycle | https://nashville.bcycle.com | 844-982-4533 | Nashville@bcycle.com');
    });

    it('returns pricing plan information', async () => {
      const response = await bot.sendAndWaitForResponse('@hubot bcycle price');
      assert.equal(response, 'Single Ride Pass Online ($5) - $5 per 30 minutes. Total minutes calculated and billed the following day.\nGuest Pass ($25) - Unlimited 120-minute rides in a 3-Day period. Additional rental fee of $3 per 30 minutes for rides longer than 120 minutes.\nMonthly Pass ($20) - Enjoy unlimited 60-minute rides for 30 days! Rides longer than 60 minutes are subject to a usage fee of $3 per additional 30 minutes.\nAnnual Pass ($120) - Enjoy unlimited 120-minute rides for a year! *Limited time offer of 120-minutes.* Rides longer than 120 minutes are subject to a usage fee of $3 per additional 30 minutes.\nSingle Ride Pass  ($5) - $5 per 30 minutes. Total minutes calculated and billed the following day.');
    });
  });

  describe('missing configuration', () => {
    let bot;

    before(async () => {
      bot = await createTestBot({ BCYCLE_CITY: null, BCYCLE_DEFAULT_STATIONS: null });
    });

    after(() => bot.shutdown());

    it('returns an error message', async () => {
      const response = await bot.sendAndWaitForResponse('@hubot bcycle');
      assert.equal(response, 'You must configure BCYCLE_CITY before use.');
    });
  });
});

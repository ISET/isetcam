# computational imaging classes todo list.
# D.Cardinal current as of Jan 4, 2021

NEAR TERM:
* support pbrt lens files by correctly processing oi returns
* figure out a rational rendered scene caching strategy
* add support for non-pbrt input scenes
* figure out how to emulate dark/"night" scenes, etc.
    Brian says I should be able to use the spd on lights
    and if not then set the mean illuminance on return
    need to check actual voltages to make sure the issue
    isn't that the sensor/ip are doing AE of some sort
* maybe do something useful with Portrait & Scenic intents, etc.
* look at Brian's suggestion of focus stacking

LONGER TERM:
* more complex processing framework to start using ai or whatever
* add support for multiple camera modules

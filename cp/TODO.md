# computational photography classes todo list.
# D.Cardinal current as of Feb 1, 2021

NEAR TERM:
* fix how we calculate exposure times for pre-computed hdr images
* walk through registration & tonemap examples to sift out bugs
* support pbrt lens files by correctly processing oi returns -- right now we don't have the right FOV
* maybe do something useful with Portrait & Scenic intents, etc.
* Fix focus stacking. "Runs" but we aren't getting variable focus

MEDIUM TERM:
* Decide how to handle receiving bracketed JPEGs as input -- should we try to "re-capture" them with our camera,
  or just treat them as ready for our advanced IP?
* Codify architecture so students have a platform on which they know how to build.

LONGER TERM:
* more complex processing framework to start using ai or whatever
* add support for multiple camera modules

STUDENT PROJECT IDEAS:
* Do burst work better than brackets for hdr capture?
* Implement various algorithms found in literature to improve on baseline
  (e.g. ML based registration, localized registration)
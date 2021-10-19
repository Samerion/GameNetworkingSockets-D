# Steam GameNetworkingSockets for D

D bindings for Valve's [GameNetworkingSockets](https://github.com/ValveSoftware/GameNetworkingSockets).

Note, a majority of the things included within the bindings are of internal use to Valve and might have been copied over
just because they were included in the public headers. They probably don't matter. I don't use them. I don't either use
bindings to proprietary Steam services, which are included in the API. Most common APIs are guaranteed, to work, the
rest is not.

DUB note: You will need to link against `GameNetworkingSockets` within your DUB config; this will not be done in this
repo to avoid possible linking problems when crosscompiling. To do so, add `"libs": ["GameNetworkingSockets"]` to your
dub.json.

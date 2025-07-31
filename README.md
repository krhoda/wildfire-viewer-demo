## Wildfire Monitoring UI

This repository contains everything needed to run a web-service + UI that shows all current wildfires in the United States.

To run the program (without building it) and view this UI, from the root of the repository, one can simply:

```bash
$ cd ui
$ npm i
$ npm run build
$ cd ../server
$ mix run --no-halt
```
Or, use the `run.sh` file, if prefered. 

The `.tool-versions` file should enforce the existence of both `mix` and `npm` by specifying elixir and node versions. These are the only tools expected to build / run this project.

Alternatively, you can use the `build.sh` file, then from `<repo>/server` run:
```bash
$ _build/dev/rel/server/bin/server start
```
Or, use `build_and_run.sh`, which will compile the Elixir program and run it using the above command.

Regardless of how it is run, the static UI will be available at [localhost:4000](http://localhost:4000) and will automatically connect to the server's websocket route.

The UI consists of a Leaflet-based map centered on North America and a set of pins and (if available) perimeters generated from the WebSocket fire data, if either a pin or perimeter is clicked, it will show the name of the incident.

The actual UI is housed in the `ui` folder, the build command found in `ui`'s `package.json` replaces the contents of the repo's `server/priv/static` with the output of the UI build (along with some vendored images which are used by the map). By combining the WebSocket server with a route to serve the static files that make up the UI, it's a very simple application from a deployment perspective. 


This service could easily be packaged in a docker container, or is currently so simple, it could just be built and SCP'd.

This service makes 1 request a minute to the Wildfire API, the API's docs say it only updates once every 15 minutes, so one could time this less aggressively.

This services uses GenServer state to manage statefulness (rather than postgres). The process constructed in `server/lib/server/ingest.ex` will keep the last response from the wildfire API in it's state, and when a new connection joins, the new connection is given a copy of the last response. If, for some reason, a user joins and the GenServer does not have a copy of the output, then the GenServer makes a new request to the API and broadcasts the result to all connections.

There is no wait for a new user to see the latest data, nor does it cause much overhead.

## Missing Pieces:

### Testing:
I wasn't able to find time to write tests, which would have been ideal, but I wanted to make sure I had something workable to show. I would want to particularly test running into timeouts/rate limits/other API errors, testing websocket disconnections and reconnections, the UI's ability to handle malformed data, then looking at coverage reports to add more.

### Telemetry 
I skipped telemetry / monitoring for the same reason as testing, I wanted to emphasize features that someone can see, but telemetry would be very important. I would want to record failed requests to the API, websocket disconnections, number of WS connections, and how long it takes to broadcast to call connections to begin with, then consider other metrics to monitor.

### Robust Deployment
This could easily be packaged in a Dockerfile, but using a `.tool-version` file and a very simple build system seemed like enough for a prototype/demo.

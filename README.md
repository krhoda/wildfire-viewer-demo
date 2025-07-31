## Wildfire Monitoring UI

This repository contains everything needed to run a web-service + UI that shows all current fires in the United States.

To run and view this program, from the root of the repository, one can simply:
```bash
$ cd server
$ mix run --no-halt
```
Or, use the `run.sh` file, if prefered. The `.tool-versions` file should enforce consistency between them.

Then, visit `localhost:4000` and the UI will be statically served.

The UI consists of a Leaflet-based map centered on North America and a set of pins generated from the WebSocket fire data. Each pin, when clicked on, will display the name of the incident. 

The actual UI is housed in the `ui` folder, the build command found in `ui`'s `package.json` replaces the contents of the repo's `server/priv/static` with the output of the UI build (along with some vendored images which are used by the map). By combining the WebSocket server with a route to serve the static files that make up the UI, it's a very simple application from a deployment perspective. 

This service could easily be packaged in a docker container, or is currently so simple, it could just be built and SCP'd.

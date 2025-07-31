#!/bin/bash
cd ui
npm i
npm run build
cd ../server
mix release
_build/dev/rel/server/bin/server start

#!/bin/bash
cd ui
npm i
npm run build
cd ../server
mix release

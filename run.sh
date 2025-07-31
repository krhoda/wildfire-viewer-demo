#!/bin/bash
cd ui
npm i
npm run build
cd ../server
mix run --no-halt

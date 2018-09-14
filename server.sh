#!/bin/bash

yarn build
bundle exec rackup -p9292 --host 0.0.0.0


#!/bin/bash

yarn build
bundle exec rackup -p80 --host 0.0.0.0


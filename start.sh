#!/bin/bash

cd /usr/src/app

echo "Booting configurator..."
cd configurator
rake db:create db:migrate db:seed
./bin/rails server \
  -b 0.0.0.0 \
  -p 8080 \
  --pid /tmp/puma-configurator.pid &
echo "Done!"

cd ..

echo "Booting runner..."
cd runner
rake db:create db:migrate
./bin/rails server \
  -b 0.0.0.0 \
  -p 3000 \
  --pid /tmp/puma-runner.pid

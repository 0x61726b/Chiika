#!/usr/bin/env bash

git clone https://github.com/creationix/nvm.git /tmp/.nvm
source /tmp/.nvm/nvm.sh
nvm install "$NODE_VERSION"
nvm use --delete-prefix "$NODE_VERSION"

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  export DISPLAY=:99.0
  sh -e /etc/init.d/xvfb start
  sleep 3
fi

node --version
npm --version

npm install
./node_modules/.bin/bower install
npm install
sleep 3
npm install
sleep 3
npm install
sleep 3
npm run preparetesting
ls ./.serve
ls ./node_modules/.bin
#./node_modules/.bin/electron .
npm test
ls /home/travis/.config/chiika
sleep 5
cat /home/travis/.config/chiika/chiika.log

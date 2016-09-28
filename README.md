![Chiika](https://raw.githubusercontent.com/arkenthera/Chiika/master/resources/icon.png)

[![Dependency Status](https://david-dm.org/arkenthera/chiika.svg)](https://david-dm.org/arkenthera/chiika)
[![Build Status](https://travis-ci.org/arkenthera/Chiika.svg?branch=master)](https://travis-ci.org/arkenthera/Chiika)
[![Build status](https://ci.appveyor.com/api/projects/status/y28jtt8iic29kbon?svg=true)](https://ci.appveyor.com/project/arkenthera/chiika)


[Chiika](http://chiika.moe/) is an upcoming cross platform desktop application which helps you manage anything related to your anime/manga.Chiika is written with [Electron](https://github.com/atom/electron)

#Running

Use NPM to build and run Chiika.You will be greeted with login screen,there you can login with your account.Your user info and lists will be retrieved upon login.

## Requirements
- NPM & NodeJS
- Node-gyp & (Msvc or Gcc/Clang) & Electron 1.3.1 for [media-detect](https://github.com/arkenthera/media-detect)

## How to build everything

Run the commands below.

```
git submodule update --init --recursive
npm install -g gulp bower
npm install

// Build media-detect
cd vendor/media-detect
npm install
npm run conf
npm run rebuild

//Build anitomy-node
cd vendor/anitomy-node
git submodule update --recursive --init
npm install
npm run conf
npm run rebuild


bower install
gulp serve

```

#Docs

See [docs](https://github.com/arkenthera/Chiika/blob/master/docs/README.md).

#Current Features

- Scripting support for users to extend functionality
- Full MAL,Hummingbird implementation.
- You can use multiple accounts at once, meaning it is possible to use both **MAL** and **Hummingbird** or **Anilist** at the **same** time.
- Anime video files/media player recognition. Supported natively on Windows, via browser extensions on Linux and OSX. See [streaming docs](https://github.com/arkenthera/Chiika/blob/master/docs/streaming.md)
- Calendar using [Senpai](http://senpai.moe) season data


#Contributing

If you'd like to help us develop Chiika, send me an email.


#Some Screenshots

![](http://i.imgur.com/ttgemAa.png)
![](http://i.imgur.com/nVP4Hxv.png)
![](http://i.imgur.com/KHfJgS4.png)
![](http://i.imgur.com/tI3IUc7.png)
![](http://i.imgur.com/anlTzK5.png)
![](http://i.imgur.com/JlDAlkK.png)

#Testing

Chiika uses [Spectron](https://github.com/electron/spectron) and [Mocha](https://mochajs.org) to run tests on Continous Integration environment.
To run tests just type ```npm test```.


![](http://i.imgur.com/2ZB21Dp.png)
![](http://i.imgur.com/jVTHOYO.png)

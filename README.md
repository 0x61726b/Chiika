![Chiika](https://raw.githubusercontent.com/arkenthera/Chiika/master/resources/icon.png)

[![Dependency Status](https://david-dm.org/arkenthera/chiika.svg)](https://david-dm.org/arkenthera/chiika)
[![Build Status](https://travis-ci.org/Chiika-Anime/Chiika.svg?branch=master)](https://travis-ci.org/arkenthera/Chiika)
[![Code Climate](https://codeclimate.com/github/arkenthera/Chiika/badges/gpa.svg)](https://codeclimate.com/github/arkenthera/Chiika)
[![Test Coverage](https://codeclimate.com/github/arkenthera/Chiika/badges/coverage.svg)](https://codeclimate.com/github/arkenthera/Chiika/coverage)
[![Issue Count](https://codeclimate.com/github/arkenthera/Chiika/badges/issue_count.svg)](https://codeclimate.com/github/arkenthera/Chiika)

[Chiika](http://chiika.moe/) is an upcoming cross platform desktop application which helps you manage anything related to your anime/manga.Chiika is written with [Electron](https://github.com/atom/electron) and powers [Chiika-Node](https://github.com/arkenthera/chiika-node) alongside with [Chiika Api](https://github.com/arkenthera/ChiikaApi).

#Building on Windows

To build Chiika you have to first build [Chiika Api](https://github.com/arkenthera/ChiikaApi) then [Chiika-Node](https://github.com/arkenthera/chiika-node).

#Dependencies
All third party dependencies will be built by CMake but you will need these prerequisities

1. Visual Studio 2013
2. [Node.js](https://nodejs.org/en/)
3. [Node-gyp](https://github.com/nodejs/node-gyp)
4. [CMake](https://cmake.org/)


#Getting Started,

```
git clone https://github.com/arkenthera/Chiika
cd Chiika/Python
python magic.py
```
Magic.py will pull all repositories and submodules required for building.

###Directory structure

It is necessary that you follow the recommended directory structure so you wont run into any problems when building.
```
...
  -Chiika/
  -Chiika/lib/chiika-node/build
  -Chiika/ChiikaApi/build
```

CD to ChiikaApi and create a directory called 'build',run CMake in the build folder.After generating the .SLN file build the solution.

When the building of ChiikaApi is done,

```
cd chiika-node
npm install
npm run rebuild
```

The final build step is now complete.

```
cd Chiika
npm install
gulp serve
```

If everything is successful the application should launch.


#License

(The MIT License)

Copyright (c) 2016 arkenthera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

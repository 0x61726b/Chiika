![Chiika](https://raw.githubusercontent.com/arkenthera/Chiika/master/resources/icon.png)


Chiika is an upcoming cross platform desktop application which helps you manage anything related to your anime/manga.Chiika is written with [Electron](https://github.com/atom/electron) and powers [Chiika-Node](https://github.com/arkenthera/chiika-node) alongside with [Chiika Api](https://github.com/arkenthera/ChiikaApi).

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
  -chiika-node/
  -ChiikaApi/
```

If you run the Magic.py you'll get the above structure.

CD to ChiikaApi and run CMake,set -DCopyFinalDepsDir=<chiika-node>/<deps> for automatic copying of the DLLs generated.After generating the .SLN file run then build.

When the building of ChiikaApi is done,

```
cd chiika-node
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

Copyright (c) 2012 Nathan Rajlich <nathan@tootallnate.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

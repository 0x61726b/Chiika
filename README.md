![Chiika](https://raw.githubusercontent.com/arkenthera/Chiika/master/resources/icon.png)

[![Dependency Status](https://david-dm.org/arkenthera/chiika.svg)](https://david-dm.org/arkenthera/chiika)
[![Build Status](https://travis-ci.org/arkenthera/Chiika.svg?branch=master)](https://travis-ci.org/arkenthera/Chiika)
[![Build status](https://ci.appveyor.com/api/projects/status/y28jtt8iic29kbon?svg=true)](https://ci.appveyor.com/project/arkenthera/chiika)


[Chiika](http://chiika.moe/) is an upcoming cross platform desktop application which helps you manage anything related to your anime/manga.Chiika is written with [Electron](https://github.com/atom/electron)

#Running

Use NPM to build and run Chiika.You will be greeted with login screen,there you can login with your account.Your user info and lists will be retrieved upon login. Media detection only works on Windows *for now*.

```
npm install -g gulp bower
npm install
bower install
gulp serve

```

#Current Features

- Scripting support for users to extend functionality
- MyAnimelist,Hummingbird and Anilist support out of the box (you can always add more library providers with scripting)
- You can use multiple accounts at once, meaning it is possible to use both **MAL** and **Hummingbird** or **Anilist** at the **same** time.
- Very easy to use public API for scripters
- User Interface is exposed to public API so you can customize the app to your will
- Anime video files/media player recognition *Only available for Win32 for now*
- Calendar using [Senpai](http://senpai.moe) season data
- Rich list/grid features (sorting,filtering etc.)


#Contributing

If you'd like to help us develop Chiika, send me an email.


#Some Screenshots

![](http://i.imgur.com/nUGQzRb.png)
![Scrobbler](http://i.imgur.com/gsAtn1L.png)

#Testing

Chiika uses [Spectron](https://github.com/electron/spectron) and [Mocha](https://mochajs.org) to run tests on Continous Integration environment.
To run tests just type ```npm test```.


![](http://i.imgur.com/2ZB21Dp.png)
![](http://i.imgur.com/jVTHOYO.png)

#License

(The MIT License)

Copyright (c) 2016 arkenthera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

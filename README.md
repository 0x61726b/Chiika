![Chiika](https://raw.githubusercontent.com/arkenthera/Chiika/master/resources/icon.png)

[![Dependency Status](https://david-dm.org/arkenthera/chiika.svg)](https://david-dm.org/arkenthera/chiika)
[![Build Status](https://travis-ci.org/arkenthera/Chiika.svg?branch=master)](https://travis-ci.org/arkenthera/Chiika)
[![Code Climate](https://codeclimate.com/github/arkenthera/Chiika/badges/gpa.svg)](https://codeclimate.com/github/arkenthera/Chiika)
[![Test Coverage](https://codeclimate.com/github/arkenthera/Chiika/badges/coverage.svg)](https://codeclimate.com/github/arkenthera/Chiika/coverage)
[![Issue Count](https://codeclimate.com/github/arkenthera/Chiika/badges/issue_count.svg)](https://codeclimate.com/github/arkenthera/Chiika)

[Chiika](http://chiika.moe/) is an upcoming cross platform desktop application which helps you manage anything related to your anime/manga.Chiika is written with [Electron](https://github.com/atom/electron)

![Login](http://i.imgur.com/56cRNUx.png)
![Screenshot - Anime List](http://i.imgur.com/lK4llMI.png)
![Details](http://i.imgur.com/r6KHf7T.png)
![Scrobbler](http://i.imgur.com/gsAtn1L.png)

#Running

Use NPM to build and run Chiika.You will be greeted with login screen,there you can login with your MyAnimeList account.Your user info and lists will be retrieved upon login. Media detection only works on Windows *for now*.

```
npm install -g gulp bower
npm install
bower install
gulp serve

```

#Current Features

- Full MyAnimelist integration (Anime/Manga list)
- Local database using NoSQL
- Anime video files/media player recognition *Win32*
- Calendar using [Senpai](senpai.moe) season data
- Searching & scraping off anime data from MyAnimelist
- Rich list/grid features (sorting,filtering etc.)





#License

(The MIT License)

Copyright (c) 2016 arkenthera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

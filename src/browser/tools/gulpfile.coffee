#----------------------------------------------------------------------------
#Chiika
#Copyright (C) 2016 arkenthera
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#Date: 23.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------
gulp = require('gulp')
sourcemaps = require "gulp-sourcemaps"
plumber = require "gulp-plumber"
del = require 'del'

serveDir = ".serve"
gulp.task 'hue', (done) ->

  watch = require "gulp-watch"
  coffee = require "gulp-coffee-react"


  gulp.src('test/test.coffee')
    .pipe(watch('test/test.coffee', {verbose: true}))
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(serveDir))
  done()


gulp.task 'hue2', (done) ->
  watch = require "gulp-watch"
  coffee = require "gulp-coffee-react"


  gulp.src('src/*.coffee')
    .pipe(watch('src/*.coffee', {verbose: true}))
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(serveDir + "/src"))
  done()

gulp.task 'hue3', (done) ->
  watch = require "gulp-watch"
  coffee = require "gulp-coffee-react"

  gulp.src('index.coffee')
    .pipe(watch('index.coffee', {verbose: true}))
    .pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(serveDir))
  done()

gulp.task 'watch_me_change', (done) ->
  delete require.cache[require.resolve('./test/test')]
  test = require './test/test'

  done()

gulp.task 'all',['hue','hue2','hue3'], (done) ->
  test = require './test/test'
  gulp.watch(['test/test.coffee',"src/*.coffee"],['watch_me_change'])
  done()

gulp.task 'clean', (done) ->
  del [serveDir], () -> done()

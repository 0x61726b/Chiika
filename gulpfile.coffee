srcDir      = 'src'
serveDir    = '.serve'
distDir     = 'dist'
releaseDir  = 'release'

# ---------------------------
#
# ---------------------------

packageJson = require('./package.json')

gulp = require('gulp')
fs = require('fs')
del = require('del')
argv = require('yargs').argv
mainBowerFiles = require('main-bower-files')
ep = require('electron-prebuilt')

packager = require('electron-packager')

# gulps
sourcemaps = require "gulp-sourcemaps"
plumber = require "gulp-plumber"

Compile_scss_files_with_sourcemaps = () ->
  gulp.task 'compile:styles', () ->

    sass = require "gulp-sass"

    gulp.src([srcDir + '/styles/**/*.scss'])
      .pipe(sourcemaps.init())
      .pipe(sass())
      .pipe(sourcemaps.write('.'))
      .pipe(gulp.dest(serveDir + '/styles'))

Inject_css___compiled_and_depedent___files_into_html = () ->
  gulp.task 'inject:css', ['compile:styles'], () ->

    inject = require "gulp-inject"
    concat = require "gulp-concat"
    files = mainBowerFiles().concat([serveDir + '/styles/**/*.css'])
    options =
      relative: true
      ignorePath: ['../../.serve', '..']
      addPrefix: '..'

    gulp.src(srcDir + '/**/*.html')
        .pipe(inject(gulp.src(files),options))
        .pipe(gulp.dest(serveDir))

Copy_assets = () ->
  gulp.task 'misc', () ->
    gulp.src(srcDir + '/assets/**/*')
      .pipe(gulp.dest(serveDir + '/assets'))
      .pipe(gulp.dest(distDir + '/assets'))

Incremental_compile_cjsx_coffee_files_with_sourcemaps = () ->
  gulp.task 'compile:scripts:watch', (done) ->

    watch = require "gulp-watch"
    coffee = require "gulp-coffee-react"

    gulp.src('src/**/*.{cjsx,coffee}')
      .pipe(watch('src/**/*.{cjsx,coffee}', {verbose: true}))
      .pipe(plumber())
      .pipe(sourcemaps.init())
      .pipe(coffee())
      .pipe(sourcemaps.write('.'))
      .pipe(gulp.dest(serveDir))
    done()

Compile_scripts_for_distribution = () ->
  gulp.task 'compile:scripts', () ->

    coffee = require "gulp-coffee-react"

    gulp.src('src/**/*.{cjsx,coffee}')
      .pipe(plumber())
      .pipe(coffee())
      .pipe(gulp.dest(distDir))

Inject_renderer_bundle_file_and_concatnate_css_files = () ->
  gulp.task 'html', ['inject:css'], () ->

    useref = require "gulp-useref"
    gulpif = require "gulp-if"
    minify = require "gulp-minify-css"

    assets = useref.assets({searchPath: ['bower_components', serveDir + '/styles']});

    gulp.src(serveDir + '/renderer/**/*.html')
    .pipe(assets)
    .pipe(gulpif('*.css', minify()))
    .pipe(assets.restore())
    .pipe(useref())
    .pipe(gulp.dest(distDir + '/renderer'))

Copy_fonts_file = () ->

  flatten = require "gulp-flatten"

  # You don't need to copy *.ttf nor *.svg nor *.otf.
  gulp.task 'copy:fonts', () ->
    gulp.src('bower_components/**/fonts/*.woff')
      .pipe(flatten())
      .pipe(gulp.dest(distDir + '/fonts'))

Copy_Node_modules = () ->
  gulp.task 'copy:dependencies', () ->

    dependencies = []

    for name of packageJson.dependencies
      dependencies.push(name)

    gulp.src('node_modules/{' + dependencies.join(',') + '}/**/*')
      .pipe(gulp.dest(distDir + '/node_modules'))

Write_a_package_json_for_distribution = () ->
  gulp.task 'packageJson', ['copy:dependencies'], (done) ->

    _ = require('lodash')

    json = _.cloneDeep(packageJson)
    json.main = './browser/Application.js'
    fs.writeFile(distDir + '/package.json', JSON.stringify(json), () -> done())

Package_for_each_platforms = () ->

  gulp.task 'package', ['win32', 'darwin', 'linux'].map (platform) ->

    taskName = 'package:' + platform

    gulp.task taskName, ['build'], (done) ->

      packager options =
        dir: distDir
        name: 'Chiika'
        arch: 'ia32'
        platform: platform
        out: releaseDir + '/' + platform
        version: '0.36.3'
      , (err) -> done()

    return taskName

gulp.task 'ci', () ->
  createInstaller = require('electron-installer-squirrel-windows')
  createInstaller( {
    path: './release/win32/Chiika-win32',
    "authors": 'arkenthera'
    } )

do Your_Application_will_ = () ->
  Compile_scss_files_with_sourcemaps()
  Compile_scripts_for_distribution()
  Inject_css___compiled_and_depedent___files_into_html()
  Copy_assets()
  Incremental_compile_cjsx_coffee_files_with_sourcemaps()
  Compile_scripts_for_distribution()
  Inject_renderer_bundle_file_and_concatnate_css_files()
  Copy_fonts_file()
  Copy_Node_modules()
  Write_a_package_json_for_distribution()
  Package_for_each_platforms()

  gulp.task('build', ['html', 'compile:scripts', 'packageJson', 'copy:fonts', 'misc'])
  gulp.task 'serve', ['inject:css', 'compile:scripts:watch', 'compile:styles', 'misc'], () ->
    development = null
    if argv.pls
      development = Object.create( process.env );
      development.Show_CA_Debug_Tools = 'yeah';

    electron = require('arkenthera-electron-connect').server.create({
        electron:ep,
        spawnOpt: {
          env:development || 'nope'
        }
      })
    electron.start()
    gulp.watch(['bower.json', srcDir + '/renderer/index.html'], ['inject:css'])
    gulp.watch([srcDir + '/styles/*.scss'],['inject:css'])
    gulp.watch([serveDir + '/browser/Application.js', serveDir + '/browser/**/*.js'], electron.restart)
    gulp.watch([serveDir + '/styles/**/*.css', serveDir + '/renderer/**/*.html', serveDir + '/renderer/**/*.js'], electron.reload)
  gulp.task 'clean', (done) ->
    del [serveDir, distDir, releaseDir], () -> done()
  gulp.task('default', ['build'])
  if taskListing = require "gulp-task-listing" then gulp.task "help", taskListing

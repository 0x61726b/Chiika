var ps = require('ps-node');
var md = require(process.cwd() + '/vendor/media-detect-helpers/MediaDetect.node');
var mediaPlayerList = JSON.parse((process.argv[2]));
var _ = require('lodash');
var MediaDetect = md.MediaDetect();
var util = require('util');
var moment = require('moment');
var AnitomyNode = require(process.cwd() + '/vendor/anitomy-node/AnitomyNode.node').Root;
var Anitomy = new AnitomyNode();
var findMpIntervalID;
var loopIntervalID;
var lastFoundTime;
var idleInterval = 1000; // Rate this process looks for players
var loopInterval = 1000; //Rate this process looks for players when a player is found
var string = require('string');

var currentPlayer,isPlayerRunning = false;

function runLoop() {
  if(isPlayerRunning) {
    //Check it is still running
    if(checkIfMediaPlayerStillRunning()) {
      //Ok it is running, check its open files to see if they are changed.
      //console.log("Watching player..." + currentPlayer.PID);

      var videoFile = MediaDetect.GetVideoFileOpenByPlayer({ pid: currentPlayer.PID }); //Returns null if no video file found

      if(_.isNull(videoFile)) {
        //Media Player is running, but no video file is detected
      } else {
        //Recognize the video file...
        //console.log("Current video file: " + videoFile); //videoFile example = 'E:\\Anime\\Akatsuki no Yona\\[FFF] Akatsuki no Yona [TV]\\[FFF] Akatsuki no Yona - 01v2 [2B487C34].mkv'
        var videoFileName = videoFile.substring(string(videoFile).lastIndexOf('\\') + 1);

        var AnitomyParse = Anitomy.Parse(videoFileName);
        console.log(AnitomyParse);

      }


    } else {
      //currentPlayer is closed , continue searching
      console.log("Media Player is no long running " + currentPlayer.name + ". Starting to search..");
      var formatted = lastFoundTime.format('YYYY-MM-DD HH:mm:ss Z');
      console.log("Last date " + formatted);
      currentPlayer = undefined;
      isPlayerRunning = false;
      findMpIntervalID = setInterval(findMediaPlayers,idleInterval);
      clearInterval(loopIntervalID);
    }
  }
}

function findMediaPlayers() {
  var currentOpenWindows = (MediaDetect.GetCurrentWindows());
  _.forEach(mediaPlayerList,function(value,key) {
    //console.log(value);
    var match = _.find(currentOpenWindows.PlayerArray, function(o) { return o.windowClass === value.class; });

    if(!_.isUndefined(match)) {
      isPlayerRunning = true;
      currentPlayer = value;
      clearInterval(findMpIntervalID);

      var now = moment();
      var formatted = now.format('YYYY-MM-DD HH:mm:ss Z');
      console.log("Current Player is " + currentPlayer.name + " Date:" + formatted);
      currentPlayer.PID = match.PID;
      console.log(currentPlayer);
      lastFoundTime = now;

      loopIntervalID = setInterval(runLoop,loopInterval);
    }
  })
}

function checkIfMediaPlayerStillRunning() {
  var currentOpenWindows = (MediaDetect.GetCurrentWindows()).PlayerArray;

  var match = _.find(currentOpenWindows, function(o) { return o.windowClass == currentPlayer.class });

  if(!_.isUndefined(match)) {
    return true;
  } else {
    return false;
  }
}

findMpIntervalID = setInterval(findMediaPlayers,idleInterval);

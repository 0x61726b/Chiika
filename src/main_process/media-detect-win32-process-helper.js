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

var currentPlayer,lastPlayer,currentPlayers,isPlayerRunning,isBrowserDetected = false;
var DisableBrowserDetection = process.argv[3] === 'true';

var detectedPlayers = [];
var currentBrowserLink = undefined;
var browserTitleLinkMap = {}
function findMediaPlayers() {
  var currentOpenWindows = (MediaDetect.GetCurrentWindows());
  _.forEach(mediaPlayerList,function(value,key) {
    //console.log(value);
    var match = _.filter(currentOpenWindows.PlayerArray, function(o) { return o.windowClass === value.class; });

    if(!_.isEmpty(match)) {
      _.forEach(match, function(mv,mk) {
        var findExecutableName = _.find(value.executables, function(m) { return m === mv.processName; });

        if(_.isUndefined(findExecutableName) === false) {
          var priority,type;
          if(_.isUndefined(value.browser)) {
            priority = 1; //Not a browser
          } else {
            priority = 0; //Browser
            _.assign(mv,{ browser: value });
          }
          _.assign(mv, { priority: priority,date: moment().valueOf() })

          var checkIfMpWasRunningLastTick = _.find(detectedPlayers, { processName: mv.processName });
          if(_.isUndefined(checkIfMpWasRunningLastTick) === false) {
            //It might be running but might change tabs or video file.

            if(checkIfMpWasRunningLastTick.windowTitle !== mv.windowTitle ) {
                _.remove(detectedPlayers, { windowClass: value.class });
                checkIfMpWasRunningLastTick = undefined;
            }
          }

          if(_.isUndefined(checkIfMpWasRunningLastTick)) {
            var skip = false;
            if(_.isUndefined(value.browser) === false && DisableBrowserDetection) {//This is a browser
              skip = true;
            }

            if(!skip){
              detectedPlayers.push(mv);
            }

            detectedPlayers.sort(function(a,b) {
              if(a.priority == b.priority){
                return b.date - a.date;
              }
              return b.priority - a.priority;
            });
          }
        }
      });
    } else {
      //This class doesnt exist now, check if it is on the array
      var lookForMp = _.find(detectedPlayers, { windowClass: value.class });

      if(!_.isUndefined(lookForMp)) {
        var state = { status: 'mp_closed',player: lookForMp };
        process.send(state);
      }
      _.remove(detectedPlayers, { windowClass: value.class });
      detectedPlayers.sort(function(a,b) {
        if(a.priority == b.priority){
          return moment.utc(b.date.timeStamp).diff(moment.utc(a.date.timeStamp));
        }
        return b.priority - a.priority;
      });
    }
  });
  if(detectedPlayers.length > 0) {
    //Most recent recognized player
    var cp = detectedPlayers[0];

    if(cp.priority === 1) {
      var videoFile = MediaDetect.GetVideoFileOpenByPlayer({ pid: cp.PID });

      if(_.isNull(videoFile)) {
        //Media Player is running, but no video file is detected
        var state = { status: 'mp_running_no_video' };
        process.send(state);
      } else {
        //Recognize the video file...
        //console.log("Current video file: " + videoFile); //videoFile example = 'E:\\Anime\\Akatsuki no Yona\\[FFF] Akatsuki no Yona [TV]\\[FFF] Akatsuki no Yona - 01v2 [2B487C34].mkv'
        var videoFileName = videoFile.substring(string(videoFile).lastIndexOf('\\') + 1);

        var AnitomyParse = Anitomy.Parse(videoFileName);

        var state = { status: 'mp_running_video', result: AnitomyParse, browser: false };
        process.send(state);
      }
    } else {
      //browser
      if(DisableBrowserDetection) {
        return;
      }
      var windowTitle = RemoveBrowserTitle(cp.windowTitle,cp.browser);

      if(_.isUndefined(currentBrowserLink) || windowTitle !== browserTitleLinkMap.title) {
        if(MediaDetect.CheckIfTabIsOpen({ Handle: cp.Handle, Browser:cp.browser.browser, Title: windowTitle })) {
          currentBrowserLink = MediaDetect.GetActiveTabLink({ Handle:cp.Handle, Browser:cp.browser.browser });
          browserTitleLinkMap = { link: currentBrowserLink, title: windowTitle };
        } else {
          currentBrowserLink = undefined;
          browserTitleLinkMap = {}
        }
      }
      var state = { status: 'mp_running_video', result: browserTitleLinkMap, browser: true };
      process.send(state);
    }
  }
}

function RemoveBrowserTitle(title,browser) { //Remove browser identifier
  return string(title).chompRight(" - " + browser.name).s;
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

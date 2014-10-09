var videoElement = document.querySelector("video");
var trackElement = document.querySelector("track");


var starTime = 0;
var endTime = videoElement.duration;

videoElement.addEventListener("timeupdate",
  function(event) {
    if(this.currentTime>=endTime) {
      this.currentTime=starTime;
    }
});

videoElement.play();

console.log(track);



var data = document.getElementById("data");

var cue = track.activeCues[0]; // assuming there is only one active cue

//textTrack.oncuechange = function (){
//  // "this" is a textTrack
//  var cue = this.activeCues[0]; // assuming there is only one active cue
//  if (!!cue) {
//    data.innerHTML = cue.startTime + "-" + cue.endTime + ": " + cue.text + "<br />" + data.innerHTML;
//    //  var obj = JSON.parse(cue.text); // cues can be data too :)
//  }
//}

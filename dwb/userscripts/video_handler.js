#!javascript

var home = system.getEnv("HOME");

var leader = ",",
  pageReader = "quvi --format best",
  streamer = "mplayer",
  converter = "ffmpeg",
  video_location = home + "/downloads/video/",
  mp3_location = home + "/downloads/video/converted/";

var streamVideo = function () {
  var wv = tabs.current;
  system.spawn(pageReader + " " + wv.uri +
      " --exec " + JSON.stringify(streamer + " %u"));
};

var downloadVideo = function () {
  var wv = tabs.current;
  system.spawn(pageReader + " " + wv.uri, function (json) {
    var info = JSON.parse(json);
    io.print(info.link[0].url);
    var download = new Download(info.link[0].url);
    download.destinationUri = "file://" + video_location +
      info.page_title + "." + info.link[0].file_suffix;
    io.print(download.destinationUri);
    download.start(function () {
      if (download.status === DownloadStatus.finished) {
        var convert = io.prompt("Convert to MP3? (y/N)").toLowerCase() === 'y';
        if (convert) {
          var src = video_location + info.page_title +
            "." + info.link[0].file_suffix;
          var dst = mp3_location + info.page_title + ".mp3";

          system.spawn(converter + " -i " + src + " -o " + dst);
        }

        return true;
      }
    });
  });
};

bind(leader + "vs", streamVideo, "stream_video");
bind(leader + "vd", downloadVideo, "download_video");

#!javascript

var handlers = {
  'application/pdf': {
    loc: system.getEnv("HOME") + '/downloads/pdf/',
    handler: function (file_location) {
      system.spawn('pdf ' + file_location);
    }
  }
};

var download_handler = function (wv, download, info) {
  if (typeof handlers[info.mimeType] === 'undefined') {
    io.notify("[DB] mimetype=" + info.mimeType);
    return false;
  }
  var ftHandler = handlers[info.mimeType];

  if (typeof ftHandler.loc === 'string') {
    download.destinationUri = "file://" + ftHandler.loc
      + download.SuggestedFilename;
  }

  download.start(function () {
    if (download.status === DownloadStatus.finished) {
      ftHandler.handler(ftHandler.loc + download.SuggestedFilename);
      return true;
    }
  });

  return true;
};

signals.connect('download', download_handler);

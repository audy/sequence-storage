getShareLink = function(obj, id, callback) {
  url = "/share/new?for=" + obj + "&id=" + id
  $.getJSON(url, function(result) {
    if (result.status == 'okay') {
      callback(result.value);
    } else {
      console.log('something went wrong!');
      console.log(result);
    }
  });
};

getShareExperiment = function(id) {
  getShareLink('experiment', id, function(res) {
      $('#share_experiment').html($("<a>", {
        text: 'Download Link',
        href: getURL("share/" + res),
      }));
  });
}

getShareFile = function(id) {
  getShareLink('dataset', id, function(res) {
    $('#share_file_' + id).html($("<a>", {
      text: 'Download Link',
      href: getURL("share/" + res),
    }));
  });
}

getURL = function (s) {
  return window.location.protocol + '//' + window.location.host + '/' + s
}
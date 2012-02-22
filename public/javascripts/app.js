getShareLink = function(obj, id, callback) {
  url = "/sharelink?for=" + obj + "&id=" + id
  $.getJSON(url, function(result) {    
    if (result.status == 'okay') {
      callback(result.value);
    } else {
      callback('failed!');
    }
  });
};

getShareExperiment = function(id) {
  getShareLink('experiment', id, function(res) {
    $("#share_experiment").html("http://" + res);
  });
}

getShareFile = function(id) {
  getShareLink('file', id, function(res) {
    $("#share_link_" + id).html("http://" + res);
  });
}
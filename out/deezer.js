// Generated by CoffeeScript 2.5.1
(function() {
  var request, sync;

  request = require("request");

  sync = require("sync-request");

  exports.get_main_user = function(token) {
    return JSON.parse(sync("get", `https://api.deezer.com/user/me?access_token=${token}`).getBody("utf8"));
  };

  exports.create_playlist = function(name, token, pblc = true, collaborative = false, description = "Made using Mikedrop") {
    var playlist, user_id;
    user_id = exports.get_main_user(token).id;
    playlist = JSON.parse(sync("POST", `https://api.deezer.com/user/${user_id}/playlists?title=${escape(name)}&access_token=${token}`).getBody("utf8"));
    exports.update_playlist(playlist, token, `description=${escape(description)}&public=${pblc}&collaborative=${collaborative}`);
    return playlist;
  };

  exports.update_playlist = function(playlist, token, parameters = "") {
    if (parameters !== "") {
      parameters = `&${parameters}`;
    }
    return sync("POST", `https://api.deezer.com/playlist/${playlist.id}?access_token=${token}${parameters}`);
  };

  exports.add_playlist_tracks = function(playlist, tracks, token) {
    var track, track_ids;
    track_ids = ((function() {
      var i, len, results;
      results = [];
      for (i = 0, len = tracks.length; i < len; i++) {
        track = tracks[i];
        results.push(track.id);
      }
      return results;
    })()).join(',');
    return JSON.parse(sync("POST", `https://api.deezer.com/playlist/${playlist.id}/tracks?access_token=${token}&songs=${track_ids}&request_method=post`).getBody("utf8"));
  };

  exports.get_playlist_tracks = function(playlist, limit = 25, offset = 0) {
    return JSON.parse(sync("get", `${playlist.tracklist}?limit=${limit}&index=${offset}`).getBody("utf8")).data;
  };

  exports.get_by_id = function(id, obj_type) {
    return JSON.parse(sync("get", `https://api.deezer.com/${obj_type}/${id}`).getBody("utf8"));
  };

  exports.search = function(query, search_type, limit = 5, offset = 0) {
    var response;
    response = void 0;
    if (search_type !== "") {
      response = JSON.parse(sync("GET", `https://api.deezer.com/search/${search_type}?q=${escape(query.replace(/[^\x00-\x7F]/g, ''))}&limit=${limit}&index=${offset}`).getBody("utf8"));
    } else {
      response = JSON.parse(sync("GET", `https://api.deezer.com/search?q=${escape(query.replace(/[^\x00-\x7F]/g, ''))}&limit=${limit}&index=${offset}`).getBody("utf8"));
    }
    return response.data;
  };

  exports.search_playlists = function(query, limit = 5, offset = 0) {
    return exports.search(query, "playlist", limit, offset);
  };

  exports.search_tracks = function(query, limit = 5, offset = 0) {
    return exports.search(query, "track", limit, offset);
  };

}).call(this);
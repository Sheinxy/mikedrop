// Generated by CoffeeScript 2.5.1
(function() {
  window.create_from_name = function(origin, playlist, token) {
    return fetch(`/${origin}/create`, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({playlist, token})
    }).then(function(res) {
      return res.json();
    }).then(function(res) {
      return conversion_end(res);
    });
  };

  window.create_from_id = function(origin, playlist_id, token) {
    return fetch(`/${origin}/create`, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({playlist_id, token})
    }).then(function(res) {
      return res.json();
    }).then(function(res) {
      return conversion_end(res);
    });
  };

  window.conversion_end = function(data) {
    var deezer_image, deezer_link, spotify_image, spotify_link;
    if (data.error) {
      return document.querySelector("#loading").textContent = "An error occured";
    } else {
      document.querySelector("#deezer").style = "";
      deezer_link = document.querySelector("#deezer-link");
      deezer_link.style = "";
      deezer_link.href = `https://www.deezer.com/playlist/${data.deezer_id}`;
      deezer_image = document.querySelector("#deezer-image");
      deezer_image.src = data.deezer_image;
      document.querySelector("#spotify").style = "";
      spotify_link = document.querySelector("#spotify-link");
      spotify_link.style = "";
      spotify_link.href = `https://open.spotify.com/playlist/${data.spotify_id}`;
      spotify_image = document.querySelector("#spotify-image");
      spotify_image.src = data.spotify_image;
      return document.querySelector("#loading").style = "display: none";
    }
  };

}).call(this);

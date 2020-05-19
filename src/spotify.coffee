request = require "request"
sync = require "sync-request"


exports.get_client_credentials = (authorization, callback) ->
    authOptions = {
    url: 'https://accounts.spotify.com/api/token',
    headers: {
        "Authorization": "Basic #{authorization}"
    },
    form: {
        grant_type: "client_credentials"
    },
    json: true
    }
    request.post(authOptions, (error, response, body) ->
        callback body.access_token
    )


exports.get_main_user = (token) ->
    return JSON.parse sync("GET", "https://api.spotify.com/v1/me/", 
        {headers:{"Authorization": "Bearer #{token}"}}).getBody("utf8")

exports.create_playlist = (name, token, pblc=true, collaborative=false, description="Made using Mikedrop") ->
    user_id = exports.get_main_user(token).id
    headers = {
        "Authorization": "Bearer #{token}",
        "Content-Type": "application/json"
    }
    json = {
        "name": escape(name),
        "public": pblc,
        "collaborative": collaborative,
        "description": escape(description)
    }
    return JSON.parse sync("POST", "https://api.spotify.com/v1/users/#{user_id}/playlists", {headers, json}).getBody("utf8")

exports.add_playlist_tracks = (playlist, tracks, token) ->
    headers = {
        "Authorization": "Bearer #{token}",
        "Content-Type": "application/json"
    }
    json = {
        "uris": (track.uri for track in tracks)
    }
    return JSON.parse sync("POST","https://api.spotify.com/v1/playlists/#{playlist.id}/tracks", {headers, json}).getBody("utf8")

exports.get_playlist_tracks = (playlist, token, limit=25, offset=0) ->
    return JSON.parse(sync("GET", "https://api.spotify.com/v1/playlists/#{playlist.id}/tracks?limit=#{limit}&offset=#{offset}", 
            {headers:{"Authorization": "Bearer #{token}"}}).getBody("utf8")).items

exports.get_by_id = (id, obj_type, token) ->
    return JSON.parse(sync("GET", "https://api.spotify.com/v1/#{obj_type}/#{id}", 
            {headers:{"Authorization": "Bearer #{token}"}}).getBody("utf8"))

exports.search = (query, search_type, token, limit=5, offset=0) ->
    return JSON.parse(sync("GET", "https://api.spotify.com/v1/search?q=#{escape(query.replace(/[^\x00-\x7F]/g, ''))}&type=#{search_type}&limit=#{limit}&offset=#{offset}", 
                {headers:{"Authorization": "Bearer #{token}"}}).getBody("utf8"))["#{search_type}s"].items

exports.search_playlists = (query, token, limit=5, offset=0) ->
    
    return exports.search(query, "playlist", token, limit, offset)

exports.search_tracks = (query, token, limit=5, offset=0) ->
	return exports.search(query, "track", token, limit, offset)
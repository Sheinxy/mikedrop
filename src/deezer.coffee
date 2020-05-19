request = require "request"
sync = require "sync-request"


exports.get_main_user = (token) ->
    return JSON.parse sync("get", "https://api.deezer.com/user/me?access_token=#{token}").getBody("utf8")

exports.create_playlist = (name, token, pblc=true, collaborative=false, description="Made using Mikedrop") ->
    user_id = exports.get_main_user(token).id
    playlist = JSON.parse sync("POST", "https://api.deezer.com/user/#{user_id}/playlists?title=#{escape(name)}&access_token=#{token}").getBody("utf8")
    exports.update_playlist playlist, token, "description=#{escape(description)}&public=#{pblc}&collaborative=#{collaborative}"
    return playlist

exports.update_playlist = (playlist, token, parameters="") ->
	if parameters != ""
		parameters = "&#{parameters}"
	sync("POST", "https://api.deezer.com/playlist/#{playlist.id}?access_token=#{token}#{parameters}")

exports.add_playlist_tracks = (playlist, tracks, token) ->
    track_ids = (track.id for track in tracks).join(',')
    return JSON.parse sync("POST","https://api.deezer.com/playlist/#{playlist.id}/tracks?access_token=#{token}&songs=#{track_ids}&request_method=post").getBody("utf8")

exports.get_playlist_tracks =  (playlist, limit=25, offset=0) ->
    return JSON.parse(sync("get", "#{playlist.tracklist}?limit=#{limit}&index=#{offset}").getBody("utf8")).data

exports.get_by_id = (id, obj_type) ->
    return JSON.parse sync("get", "https://api.deezer.com/#{obj_type}/#{id}").getBody("utf8")
    
exports.search = (query, search_type, limit=5, offset=0) ->
    response = undefined
    if search_type != ""
        response = JSON.parse sync("GET", "https://api.deezer.com/search/#{search_type}?q=#{escape(query.replace(/[^\x00-\x7F]/g, ''))}&limit=#{limit}&index=#{offset}").getBody("utf8")
    else
        response = JSON.parse sync("GET", "https://api.deezer.com/search?q=#{escape(query.replace(/[^\x00-\x7F]/g, ''))}&limit=#{limit}&index=#{offset}").getBody("utf8")
    return response.data

exports.search_playlists = (query, limit=5, offset=0) ->
    return exports.search(query, "playlist", limit, offset)

exports.search_tracks = (query, limit=5, offset=0) ->
	return exports.search(query, "track", limit, offset)
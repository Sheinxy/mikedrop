deezer = require "./deezer"
spotify = require "./spotify"


exports.deezer_to_spotify = (deezer_playlist, token) ->
    playlist = deezer_playlist
    name = playlist.title
    description = playlist.description || "Made using Mikedrop"
    pblc = playlist.public || true
    collaborative = playlist.collaborative || false

    spotify_playlist = spotify.create_playlist name, token, pblc, collaborative, description

    nb_tracks = playlist.nb_tracks
    pages =  Math.floor nb_tracks // 25
    if nb_tracks % 25 != 0
        pages += 1

    for page in [0..pages - 1] by 1
        deezer_tracks = deezer.get_playlist_tracks playlist, 25, page * 25
        
        for track in deezer_tracks
            query = "#{track.title} #{track.artist.name}"
            search = spotify.search_tracks(query, token, 5)

            if search.length == 0
                query = "#{track.title.slice(0, Math.floor track.title.length / 2)} #{track.artist.name}"
                search = spotify.search_tracks(query, token, 5)

            spotify_track = 0
            error = "error" in search
            while not error and spotify_track < search.length
                adding = spotify.add_playlist_tracks(spotify_playlist, [search[spotify_track]], token)
                error = not ("error" in adding)
                spotify_track++

    return {deezer_playlist, spotify_playlist}
            

exports.spotify_to_deezer = (spotify_playlist, token, spotify_token) ->
    playlist = spotify_playlist
    name = playlist.name
    description = playlist.description || "Made using Mikedrop"
    pblc = playlist.public || true
    collaborative = playlist.collaborative || false

    deezer_playlist = deezer.create_playlist name, token, pblc, collaborative, description

    nb_tracks = playlist.tracks.total
    pages =  Math.floor nb_tracks // 25
    if nb_tracks % 25 != 0
        pages += 1

    for page in [0..pages - 1] by 1
        spotify_tracks = spotify.get_playlist_tracks playlist, spotify_token, 25, page * 25
        
        for track_dt in spotify_tracks
            track = track_dt.track
            query = "#{track.name} #{track.artists[0].name}"
            search = deezer.search_tracks(query, 5)

            if search.length == 0
                query = "#{track.name.slice(0, Math.floor track.name.length / 2)} #{track.artists[0].name}"
                search = deezer.search_tracks(query, 5)

            deezer_track = 0
            error = "error" in search
            while not error and deezer_track < search.length
                adding = deezer.add_playlist_tracks(deezer_playlist, [search[deezer_track]], token)
                error = not ("error" in adding)
                deezer_track++

    return {spotify_playlist, deezer_playlist}

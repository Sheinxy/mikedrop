express = require "express"
request = require "request"
convert = require "./convert"
deezer = require "./deezer"
spotify = require "./spotify"
require('dotenv').config()


app = express()

app.set "views", "#{__dirname}/views"
app.set "view engine", "pug" 

app.use "/css", express.static "#{__dirname}/css"
app.use "/js", express.static "#{__dirname}/js"
app.use express.json()
app.use express.urlencoded()


app.get '/', (req, res) -> res.render 'index'

app.get('/:origin', (req, res) -> 
    switch req.params.origin
        when "deezer"
            if req.query.code
                # Retrieves the access token when a code has been passed
                options = {
                    url: "https://accounts.spotify.com/api/token",
                    form: {
                        grant_type: "authorization_code",
                        code: req.query.code,
                        redirect_uri: "http://localhost:3000/deezer"
                    },
                    headers: {
                        "Authorization": "Basic #{process.env.SPOTIFY_AUTH}"
                    },
                    json: true
                }
                request.post(options, (error, response, body) ->
                    req.params["token"] = body.access_token
                    params = {
                        get: req.params
                    }
                    res.render 'convert', params
                )
            else
                # This will just retrieve the code in a way
                req.params["client_id"] = process.env.SPOTIFY_ID
                params = {
                    get: req.params
                }
                res.render 'convert', params
        when "spotify"
            if req.query.code          
                # Retrieves the access token when a code has been passed
                options = {
                    url: "https://connect.deezer.com/oauth/access_token.php?app_id=#{process.env.DEEZER_ID}&secret=#{process.env.DEEZER_SECRET}&code=#{req.query.code}&output=json",
                    json: true
                }
                request.post(options, (error, response, body) ->
                    req.params["token"] = body.access_token
                    params = {
                        get: req.params
                    }
                    res.render 'convert', params
                )
            else
                # This will just retrieve the code in a way
                req.params["client_id"] = process.env.DEEZER_ID
                params = {
                    get: req.params
                }
                res.render 'convert', params
)

app.post('/:origin', (req, res) -> 
    req.params["playlist_id"] = req.body["playlist_id"]
    req.params["playlist"] = req.body["playlist"]
    req.params["token"] = req.body["token"]
    params = {
        post: req.params
    }
    res.render 'convert', params
)

app.post('/:origin/create', (req, res) ->
    switch req.params.origin
        when "spotify"
            spotify.get_client_credentials process.env.SPOTIFY_AUTH, (spotify_token) ->
                try
                    playlist = if req.body["playlist_id"] then spotify.get_by_id(req.body["playlist_id"], "playlists", spotify_token) else spotify.search_playlists(req.body["playlist"], spotify_token)[0]
                    data = convert.spotify_to_deezer playlist, req.body["token"], spotify_token
                    spotify_image = deezer.get_by_id(data.deezer_playlist.id, "playlist").picture_xl
                    if data.spotify_playlist.images[0]
                        spotify_image = data.spotify_playlist.images[0].url
                    res.send {
                        spotify_id: data.spotify_playlist.id,
                        spotify_image: spotify_image,
                        deezer_id: data.deezer_playlist.id,
                        deezer_image: deezer.get_by_id(data.deezer_playlist.id, "playlist").picture_xl
                    }
                catch 
                    res.send {
                        "error": "An error occured"
                    }
            
        when "deezer"
            try
                playlist = if req.body["playlist_id"] then deezer.get_by_id(req.body["playlist_id"], "playlist") else deezer.search_playlists(req.body["playlist"])[0]
                data = convert.deezer_to_spotify playlist, req.body["token"]
                spotify_image = deezer.get_by_id(data.deezer_playlist.id, "playlist").picture_xl
                if data.spotify_playlist.images[0]
                    spotify_image = data.spotify_playlist.images[0].url
                res.send {
                    spotify_id: data.spotify_playlist.id,
                    spotify_image: spotify_image,
                    deezer_id: data.deezer_playlist.id,
                    deezer_image: deezer.get_by_id(data.deezer_playlist.id, "playlist").picture_xl
                }
            catch 
                res.send {
                    "error": "An error occured"
                }
        else
            res.send {error: "bad origin"}
)

app.listen 3000
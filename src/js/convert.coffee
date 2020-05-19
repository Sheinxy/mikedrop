window.create_from_name = (origin, playlist, token) ->
    fetch("/#{origin}/create", {
        method: "POST",
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
        },
        body: JSON.stringify {playlist, token}
    })
    .then( (res) -> return res.json())
    .then( (res) -> conversion_end res)

window.create_from_id = (origin, playlist_id, token) ->
    fetch("/#{origin}/create", {
        method: "POST",
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
        },
        body: JSON.stringify {playlist_id, token}
    })
    .then( (res) -> return res.json())
    .then( (res) -> conversion_end res)

window.conversion_end = (data) ->
    if data.error
        document.querySelector("#loading").textContent = "An error occured"
    else
        document.querySelector("#deezer").style = ""
        deezer_link = document.querySelector "#deezer-link"
        deezer_link.style = ""
        deezer_link.href = "https://www.deezer.com/playlist/#{data.deezer_id}"
        deezer_image = document.querySelector "#deezer-image"
        deezer_image.src = data.deezer_image


        document.querySelector("#spotify").style = ""
        spotify_link = document.querySelector "#spotify-link"
        spotify_link.style = ""
        spotify_link.href = "https://open.spotify.com/playlist/#{data.spotify_id}"
        spotify_image = document.querySelector "#spotify-image"
        spotify_image.src = data.spotify_image

        document.querySelector("#loading").style = "display: none"
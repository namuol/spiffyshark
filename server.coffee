config = require './config'
GroovesharkClient = require 'grooveshark'
zappa = require 'zappajs'
Parse = require 'kaiseki'
knox = require 'knox'
shortid = require 'shortid'
xmldom = require 'xmldom'
DOMParser = xmldom.DOMParser
XSPF = require './public/xspf_parser'
JSON = require 'JSON'
fs = require 'fs'
async = require 'async'

{exec} = require 'child_process'
exec 'cake build'

Array::remove = (from, to) ->
  rest = @slice((to or from) + 1 or @length)
  @length = (if from < 0 then @length + from else from)
  @push.apply this, rest

alnum = (s) ->
  s.replace(/[^a-z0-9]/gi, '').toUpperCase()

gs_noauth = new GroovesharkClient config.grooveshark_key, config.grooveshark_secret
gs_noauth.authenticate config.gs_anon_acct, config.gs_anon_password, (err, status, body) =>
  if err
    throw err
  console.log 'Logged in as ' + config.gs_anon_acct

parse = new Parse config.parse_app_id, config.parse_rest_key
s3 = knox.createClient
  key: config.aws_access_key
  secret: config.aws_secret
  bucket: config.aws_s3_bucket

clients = {}

zappa.run config.port, ->
  getClient = (req) ->
    return clients[req.session.user.id]

  handle_errors = (req, res, err, status) ->
    if req.accepts 'json'
      if err and (err.length or err.error?)
        if err.length and err[0].message # gs error
          res.send err:
            msg: err[0].message
          , 500
        else
          res.send err:
            msg:err.error
          , 500
        return true
    else if req.accepts 'html'
      if err
        if err.length
          for e in err
            req.session.errors.push
              msg: e.message
          return false
        else if err.error
          req.session.errors.push
            msg: err.error
          return false
      return false

  requiresLogin = (req, res, next, redirect='/') ->
    if req.session.user
      next()
    else if req.accepts 'json'
      res.json 403, err:
        msg: 'You must be logged in to perform that operation.'
    else if req.accepts 'html'
      req.session.errors.push
        msg: 'You must be logged in to perform that operation.'
      res.redirect redirect

  @use 'bodyParser',
    static: __dirname + '/public',
    'zappa',
    'partials',
    @express.cookieParser(),
    session: secret: 'watlol',
    (req, res, next) ->
      if not req.session.errors
        req.session.errors = []
      next()

  @get '/', ->
    @render 'index',
      user: @request.session.user
      errors: @request.session.errors

    @request.session.errors = []

  searchQueue = undefined
  urlQueue = undefined

  setupSearchQueue = ->
    searchQueue = async.queue (task, cb) ->
      task cb
    , 1

    # HACK
    searchQueue.drain = ->
      setupSearchQueue()

    searchQueue.rateLimit config.gs_search_ratelimit_ms

  setupUrlQueue = ->
    urlQueue = async.queue (task, cb) ->
      task cb
    , 1

    # HACK
    urlQueue.drain = ->
      setupUrlQueue()

    urlQueue.rateLimit config.gs_url_ratelimit_ms
  
  setupSearchQueue()
  setupUrlQueue()
  
  @get '/gs_song/:id', ->
    urlQueue.push (urlCallback) =>
      gs_noauth.request 'getSongURLFromSongID',
        songID: @params.id
      , (err, status, gs_body) =>
        urlCallback()
        return if handle_errors @request, @response, err, status

        @redirect gs_body.url

  @get '/gs_album/:id', ->
    @redirect "http://grooveshark.com/album/~/#{@params.id}"

  @get '/gs_artist/:id', ->
    @redirect "http://grooveshark.com/artist/~/#{@params.id}"

  @on 'song': ->
    searchQueue.push (searchCallback) =>
      if @socket.disconnected
        searchCallback()
        return

      gs_noauth.request 'getSongSearchResults',
        query: @data.creator + ' ' + @data.title
        country: 'USA'
        limit: 30
      , (err, status, gs_body) =>
        searchCallback()

        if err? and err.length > 0
          @ack err: err
          return

        for song in gs_body.songs
          song.score = 0

          if @data.title
            if alnum(song.SongName) is alnum(@data.title)
              song.score += 30
            else if alnum(@data.title) in alnum(song.SongName)
              song.score += 10

          if @data.creator
            if alnum(song.ArtistName) is alnum(@data.creator)
              song.score += 40
            else if alnum(@data.creator) in alnum(song.ArtistName)
              song.score += 20

          if @data.album
            if alnum(song.AlbumName) is alnum(@data.album)
              song.score += 30
            else if alnum(@data.album) in alnum(song.AlbumName)
              song.score += 15

          if song.CoverArtFilename? and song.CoverArtFilename.length > 0
            song.score += 5

        gs_body.songs.sort (a, b) ->
          diff = b.score - a.score
          if diff is 0
            if a.IsVerified in [true, 'true']
              return -1
            else if b.IsVerified in [true, 'true']
              return 1
          return diff

        if gs_body.songs.length > 0
          gs_body.songs[0].selected = true
        
        @ack gs_body



  @get '/playlists', -> requiresLogin @request, @response, =>
    client = getClient @request
    client.gs.request 'getUserPlaylists', {}, (err, status, gs_body) =>
      return if handle_errors @request, @response, err, status
      parse.getUser @request.session.user.pid, (err, res, body, success) =>
        return if handle_errors @request, @response, body, res.statusCode
        @send
          gs: gs_body
          xspf:
            playlists: body.playlists
  
  saveGSPlaylist = (cb) ->
    # Basic playlist validation:
    if not (@body.jspf? and @body.jspf.playlist? and @body.jspf.playlist.track?)
      console.err 'Bad playlist body:'
      console.err @body
      @send
        okay: false
        err:
          msg: 'Your playlist appears to be formatted incorrectly!'
      , 400
      return
    
    @body.jspf.playlist.extension = @body.jspf.playlist.extension or {}

    if @request.session.user
      client = getClient(@request).gs
    else
      client = gs_noauth

    getURL = (gs_body) =>
      gs_id = gs_body.playlistID
      client.request 'getPlaylistURLFromPlaylistID',
        playlistID: gs_id
      , (err, status, gs_body) =>
        return if handle_errors @request, @response, err, status
        @body.jspf.playlist.extension[config.gs_playlist_rel] = [{
          id: gs_id
          url: gs_body.url
        }]
        cb gs_body

    if @body.gs_playlist.id?
      # Update existing playlist
      client.request 'setPlaylistSongs',
        playlistID: @body.gs_playlist.id
        songIDs: @body.gs_playlist.tracks
      , (err, status, gs_body) =>
        return if handle_errors @request, @response, err, status
        client.request 'renamePlaylist',
          playlistID: @body.gs_playlist.id
          name: @body.gs_playlist.name
        , (err, status, gs_body) =>
          return if handle_errors @request, @response, err, status
          gs_body.playlistID = @body.gs_playlist.id
          getURL gs_body
    else
      # Create new playlist
      client.request 'createPlaylist',
        name: @body.gs_playlist.name or 'Untitled'
        songIDs: @body.gs_playlist.tracks or []
      , (err, status, gs_body) =>
        return if handle_errors @request, @response, err, status
        getURL gs_body

  @post '/login', ->
    client = new GroovesharkClient config.grooveshark_key, config.grooveshark_secret
    client.authenticate @body.username, @body.password, (err, status, body) =>
      return if handle_errors @request, @response, err, status

      if not client.authenticated
        @request.session.errors.push
          msg: 'Wrong username/password combination.'
        @redirect @body.redirect or '/'
      else
        @request.session.user =
          id: body.UserID
          name: @body.username

        clients[@request.session.user.id] =
          gs: client

        parse.getUsers
          where: username: @body.username
        , (err, res, body, success) =>
          return if handle_errors @request, @response, err, res.statusCode

          if body.length is 0
            parse.createUser
              username: @body.username
              password: config.parse_user_password
              playlists: []
            , (err, res, body, success) =>
              if not handle_errors @request, @response, body, res.statusCode
                @request.session.user.ptoken = body.sessionToken
                @request.session.user.pid = body.objectId
              @redirect @body.redirect or '/'
          else
            parse.loginUser @body.username, config.parse_user_password
            , (err, res, body, success) =>
              if not handle_errors @request, @response, body, res.statusCode
                @request.session.user.ptoken = body.sessionToken
                @request.session.user.pid = body.objectId
              @redirect @body.redirect or '/'


  @post '/logout', -> requiresLogin @request, @response, =>
    client = getClient @request
    if client
      client.gs.logout (err, status, body) =>
        return if handle_errors(@request, err, status)
        delete clients[@request.session.user.id]

        @request.session.user = null
        @redirect @body.redirect or '/'

  @post '/playlist', ->
    file = @request.files.file

    fs.readFile file.path, 'utf8', (err, data) =>
      return if handle_errors @request, @response, err, 500

      try
        dom = XSPF.XMLfromString data
        jspf = XSPF.toJSPF dom
      catch err
        @response.json 400,
          err: 'There were troubles with your file. Please ensure it is a valid XSPF playlist.'
        return

      headers =
        'x-amz-acl': 'public-read'
        'Content-Type': 'application/json'
        'x-amz-meta-title': jspf.playlist.title
        'x-amz-meta-creator': jspf.playlist.creator
        'x-amz-meta-track-count': ''+jspf.playlist.track.length or '0'

      id = shortid.generate()
      if @request.session.user
        s3Path = '/'+@request.session.user.name+'/'+id
      else
        s3Path = '/!/'+id
        expires = new Date
        expires.setHours expires.getHours() + 24
        headers.Expires = expires

      s3url = s3.url(s3Path)

      fs.writeFile file.path, JSON.stringify(jspf), 'utf8', (err) =>
        return if handle_errors @request, @response, err, 500

        req = s3.putFile file.path, s3Path, headers, (err, res) =>
          if @request.session.user
            return if handle_errors @request, @response, err, res.statusCode
            parse.sessionToken = @request.session.user.ptoken
            parse.updateUser @request.session.user.pid,
              playlists:
                __op: 'Add'
                objects: [
                  title: jspf.playlist.title
                  creator: jspf.playlist.creator
                  track_count: jspf.playlist.track.length
                  id: id
                ]
            , (err, res, body, success) =>
              return if handle_errors @request, @response, body, res.statusCode
              @send
                id: id
              , 200
          else
            @send
              id: id
            , 200

  
  saveFile = (buffer, s3Path, id) ->
    gs_url = @body.jspf.playlist.extension[config.gs_playlist_rel][0].url
    gs_id = @body.jspf.playlist.extension[config.gs_playlist_rel][0].id
    creator = @body.jspf.playlist.creator
    title = @body.jspf.playlist.title
    track_count = @body.jspf.playlist.track.length

    req = s3.putBuffer buffer, s3Path,
      'Content-Length': buffer.length
      'Content-Type': 'application/json'
      'x-amz-meta-title': title
      'x-amz-meta-creator': creator
      'x-amz-meta-track-count': ''+track_count or '0'
      'x-amz-meta-gs-url': gs_url
      'x-amz-meta-gs-id': gs_id
    , (err={message:'Unexpected Error'}, res={}) =>

      if (res.statusCode >= 300) or (res.statusCode < 200)
        @send
          okay: false
          err:
            msg: 'Unexpected problem saving your playlist!'
        , 500
        return

      if not @request.session.user?
        @send
          okay: true
          gs_url: gs_url
          gs_id: gs_id
          id: id
        , 200
      else
        updateParseUserPlaylists.call @, [{
          creator: creator
          title: title
          track_count: track_count
          gs_url: gs_url
          gs_id: gs_id
          id: id
        }], (err) =>
          return if handle_errors @request, @response, err, res.statusCode
          @send
            okay: true
            gs_url: gs_url
            gs_id: gs_id
            id: id
          , 200

  updateParseUserPlaylists = (playlists, cb) ->
    found = false

    parse.getUser @request.session.user.pid, (err, res, user, success) =>
      return if handle_errors @request, @response, user, res.statusCode
      async.forEachLimit playlists, 5, (playlist, p_cb) =>
        for file in user.playlists
          if file.id is playlist.id
            file.title = playlist.title
            file.creator = playlist.creator
            file.track_count = playlist.track_count
            found = true
            parse.sessionToken = @request.session.user.ptoken
            parse.updateUser @request.session.user.pid,
              playlists: user.playlists
            , (err, res, body, success) =>
              if err?
                p_cb
                  err:
                    msg: "Unexpected error saving playlist \"#{file.creator} - #{file.title}\""
              else
                p_cb null
        if not found
          @body.jspf.playlist.track = @body.jspf.playlist.track or []
          parse.sessionToken = @request.session.user.ptoken
          parse.updateUser @request.session.user.pid,
            playlists:
              __op: 'Add'
              objects: [
                title: playlist.title
                creator: playlist.creator
                track_count: playlist.track_count
                id: playlist.id
              ]
          , (err, res, body, success) =>
            if err?
              p_cb
                err:
                  msg: "Unexpected error saving playlist \"#{file.creator} - #{file.title}\""

            p_cb null
      , (err) =>
        return if handle_errors @request, @response, user, res.statusCode
        cb null

  @post '/new_playlist', ->
    saveGSPlaylist.call @, =>
      id = shortid.generate()
      if @request.session.user
        s3Path = '/'+@request.session.user.name+'/'+id
      else
        s3Path = '/!/'+id

      s3.headFile s3Path, (err, res) =>
        if (res.statusCode < 300) and (res.statusCode >= 200)
          @send
            okay: false
            err:
              msg: 'That playlist already exists. Weird. Try saving again.'
          , 409
          return

        json = JSON.stringify @body.jspf
        buffer = new Buffer json

        saveFile.call @, buffer, s3Path, id

  @put '/save_playlist/:id', ->
    saveGSPlaylist.call @, =>
      id = @params.id
      if @request.session.user
        s3Path = '/'+@request.session.user.name+'/'+id
      else
        s3Path = '/!/'+id

      ###
      s3.headFile s3Path, (err, res) =>
        if res.statusCode != 200
          @send
            okay: false
            err:
              msg: 'That playlist does not exist (has it expired?) or you do not have permission to overwrite it.'
          , 403
          return
      ###
      json = JSON.stringify @body.jspf
      buffer = new Buffer json

      saveFile.call @, buffer, s3Path, id

  @del '/playlist/:id', -> requiresLogin @request, @response, =>
    s3Path = '/'+@request.session.user.name+'/'+@params.id

    s3.headFile s3Path, (err, res) =>
      gs_id = res.headers['x-amz-meta-gs-id']

      if gs_id?
        if @request.session.user
          client = getClient(@request).gs
        else
          client = gs_noauth

        client.request 'deletePlaylist',
          playlistID: gs_id
        , ->
          # Do nothing. If there was an error, oh well.

      s3.deleteFile s3Path, (err, res) =>
        if (res.statusCode != 404) and ((res.statusCode >= 300) or (res.statusCode < 200))
          @send
            okay: false
            err:
              msg: 'Unexpected problem deleting your playlist!'
          , 500
          return
        parse.getUser @request.session.user.pid, (err, res, user, success) =>
          return if handle_errors @request, @response, user, res.statusCode
          i=0
          found = false
          for file in user.playlists
            if file.id != @params.id
              ++i
            else
              found = true
              user.playlists.remove i
              parse.sessionToken = @request.session.user.ptoken
              parse.updateUser @request.session.user.pid,
                playlists: user.playlists
              , (err, res, body, success) =>
                return if handle_errors @request, @response, body, res.statusCode
                @send
                  okay: true
                , 200
                return
          if not found
            # Maybe they hit delete twice, somehow?
            @send
              okay: true
            , 200

  @get '/playlist/:id', ->
    anonPath = '/!/'+@params.id
    if @request.session.user
      path = '/'+@request.session.user.name+'/'+@params.id
    else
      path = anonPath

    s3.headFile path, (err, res) =>
      if res.statusCode != 200
        if @request.session.user
          path = anonPath
        else
          @send
            okay: false
            err:
              msg: 'That playlist does not exist (has it expired?).'
          , 403
          return

      buffer = ''
      req = s3.getFile path, (err, res) =>
        if res.statusCode != 200
          @send
            okay: false
            err:
              msg: 'That playlist does not exist (has it expired?).'
          , 403
          return

        res.setEncoding 'utf8'
        res.on 'data', (chunk) -> buffer += chunk
        res.on 'end', (a, b, c) =>
          if path is anonPath
            @response.set 'NotYours', 'true'

          for own k,v of res.headers
            @response.set k, v
          @send buffer

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
      if err and (err.length or err.error)
        if err.length and err[0].message # gs error
          res.send err:
            msg: err[0].message
          , 500
        else
          res.send err:
            msg:err.error
          , status
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

    searchQueue.rateLimit 50

  setupUrlQueue = ->
    urlQueue = async.queue (task, cb) ->
      task cb
    , 1

    # HACK
    urlQueue.drain = ->
      setupUrlQueue()

    urlQueue.rateLimit 150
  
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
        limit: 15
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
            console.log song.AlbumName
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
            playlists: body.uploaded_files

  @post '/grooveshark_playlist', ->
    if @request.session.user
      client = getClient(@request).gs
    else
      client = gs_noauth
    client.request 'createPlaylist',
      name: @body.title
      songIDs: @body.tracks
    , (err, status, gs_body) =>
      return if handle_errors @request, @response, err, status
      gs_noauth.request 'getPlaylistURLFromPlaylistID',
        playlistID: gs_body.playlistID
      , (err, status, gs_body) =>
        return cb(err) if err
        @send gs_body

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
              uploaded_files: []
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
              uploaded_files:
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
  @put '/save_playlist/:id', ->
    if @request.session.user
      s3Path = '/'+@request.session.user.name+'/'+@params.id
    else
      s3Path = '/!/'+@params.id

    json = JSON.stringify @body
    buffer = new Buffer json
    req = s3.putBuffer buffer, s3Path,
      'Content-Length': buffer.length
      'Content-Type': 'application/json'
    , (err, res) =>

      if res.statusCode is 200
        @send
          okay: true
        , 200
      else
        @send
          okay: false
          err:
            msg: 'Unexpected problem saving your playlist!'
        , 500

  @get '/playlist/:id', ->
    if @request.session.user
      s3Path = '/'+@request.session.user.name+'/'+@params.id
    else
      s3Path = '/!/'+@params.id

    buffer = ''
    req = s3.getFile s3Path, (err, res) =>
      res.setEncoding 'utf8'
      res.on 'data', (chunk) -> buffer += chunk
      res.on 'end', =>
        for own k,v of res.headers
          @response.set k, v
        @send buffer

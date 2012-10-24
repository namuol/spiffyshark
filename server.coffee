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
          res.send err:err, status
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
      res.json 403, err:'You must be logged in to perform that operation.'
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

  @on 'song': ->
    console.log 'SONG'
    searchQueue.push (searchCallback) =>
      console.log 'TASK'
      if @socket.disconnected
        console.log 'DISCONNECTED'
        searchCallback()
        return

      ###
      @ack
        "songs": [
            "SongID": 25279548
            "SongName": "Next Girl"
            "ArtistID": 3705
            "ArtistName": "The Black Keys"
            "AlbumID": 4151255
            "AlbumName": "Brothers"
            "CoverArtFilename": "4151255.jpg"
            "Popularity": 1229400698
            "IsLowBitrateAvailable": true
            "IsVerified": false
            "Flags": 2
            "url": "http://grooveshark.com/s/Next+Girl/2Qgvt9?src=3"
        ]

      searchCallback()
      return
      ###

      gs_noauth.request 'getSongSearchResults',
        query: @data.creator + ' ' + @data.title
        country: 'USA'
        limit: 5
      , (err, status, gs_body) =>
        searchCallback()

        console.log gs_body

        if err? and err.length > 0
          @ack err: err
          console.log err
          return
        
        @ack gs_body

        ###
        if gs_body.songs.length is 0
          @ack
            songs: []
          return

        async.forEach [gs_body.songs[0]], (song, cb) =>
          urlQueue.push (urlCallback) =>
            gs_noauth.request 'getSongURLFromSongID',
              songID: song.SongID
            , (err, status, gs_body) =>
              urlCallback()
              if err
                cb err
                return

              song.url = gs_body.url
              cb null
        , (err) =>
          if err? and err.length > 0
            @ack err: err
            return
          @ack gs_body
        ###


  @get '/playlists', -> requiresLogin @request, @response, =>
    client = getClient @request
    client.gs.request 'getUserPlaylists', {}, (err, status, gs_body) =>
      return if handle_errors @request, @response, err, status
      parse.getUser @request.session.user.pid, (err, res, body, success) =>
        return if handle_errors @request, @response, body, res.status
        @send
          gs: gs_body
          xspf:
            playlists: body.uploaded_files

  @post '/grooveshark_playlist', ->
    if @request.session.user
      client = getClient(@request).gs
    else
      client = gs_noauth
    console.log @body
    client.request 'createPlaylist',
      name: @body.title
      songIDs: @body.tracks
    , (err, status, gs_body) =>
      return if handle_errors @request, @response, err, status
      console.log err
      console.log status
      console.log gs_body
      gs_noauth.request 'getPlaylistURLFromPlaylistID',
        playlistID: gs_body.playlistID
      , (err, status, gs_body) =>
        console.log err
        console.log status
        console.log gs_body
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
          return if handle_errors @request, @response, err, res.status

          if body.length is 0
            parse.createUser
              username: @body.username
              password: config.parse_user_password
              uploaded_files: []
            , (err, res, body, success) =>
              return if handle_errors @request, @response, body, res.status
              @request.session.user.ptoken = body.sessionToken
              @redirect @body.redirect or '/'
          else
            parse.loginUser @body.username, config.parse_user_password
            , (err, res, body, success) =>
              if not handle_errors @request, @response, body, res.status
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

  @post '/upload_playlist', ->
    file = @request.files.file

    fs.readFile file.path, 'utf-8', (err, data) =>
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
        'Content-Type': 'application/xspf+xml'
      if @request.session.user
        s3Path = '/'+@request.session.user.name+'/'+shortid.generate()+'/'+file.name
      else
        s3Path = '/!/'+shortid.generate()
        expires = new Date
        expires.setHours expires.getHours() + 24
        headers.Expires = expires

      s3url = s3.url(s3Path)

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
                url: s3url
              ]
          , (err, res, body, success) =>
            return if handle_errors @request, @response, body, res.statusCode
            @send
              url: s3url
            , 200
        else
          @send
            url: s3url
          , 200

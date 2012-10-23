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
    console.log err
    console.log status
    if req.accepts 'json'
      console.log 5
      if err and (err.length or err.error)
        console.log 6
        console.error 'ERROR (json):' + err
        if err.length and err[0].message # gs error
          console.log err[0].message
          res.send err:
            msg: err[0].message
          , 500
        else
          res.send err:err, status
        console.log 7
        return true
    else if req.accepts 'html'
      console.log 1
      if err
        if err.length
          console.log 2
          for e in err
            req.session.errors.push
              msg: e.message
          return false
        else if err.error
          console.log 3
          req.session.errors.push
            msg: err.error
          return false
      console.log 4
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
  
  @get '/song', ->
    gs_noauth.request 'getSongSearchResults',
      query: @query.creator + ' ' + @query.title
      country: 'USA'
      limit: 1
    , (err, status, gs_body) =>
      console.log '==============================\\'
      console.log err
      console.log status
      console.log gs_body
      return if handle_errors @request, @response, err, status
      calls = []

      async.forEach gs_body.songs, (song, cb) =>
        gs_noauth.request 'getSongURLFromSongID',
          songID: song.SongID
        , (err, status, gs_body) =>
          return cb(err) if err
          song.url = gs_body.url
          cb null
      , (err) =>
        return if handle_errors @request, @response, err, status
        @send gs_body
        console.log '==============================/'


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

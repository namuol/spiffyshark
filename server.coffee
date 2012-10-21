config = require './config'
GroovesharkClient = require 'grooveshark'
zappa = require 'zappajs'
Parse = require 'kaiseki'
knox = require 'knox'
shortid = require 'shortid'
JSON = require 'JSON'

{exec} = require 'child_process'
exec 'cake build'

zappa.run config.port, ->
  parse = new Parse config.parse_app_id, config.parse_rest_key
  s3 = knox.createClient
    key: config.aws_access_key
    secret: config.aws_secret
    bucket: config.aws_s3_bucket

  clients = {}

  getClient = (req) ->
    return clients[req.session.user.id]

  handle_errors = (req, err, status) ->
    if req.accepts 'html'
      if err
        if err.length
          for e in err
            req.session.errors.push
              msg: e.message
          return true
        else if err.error
          req.session.errors.push
            msg: err.error
          return true
      return false
    else if req.accepts 'json'
      if err and (err.length or err.error)
        res.send err:err, status
      return true

  requiresLogin = (req, res, next, redirect='/') ->
    if req.session.user
      next()
    else if req.accepts 'html'
      req.session.errors.push
        msg: 'You must be logged in to perform that operation.'
      res.redirect redirect
    else if req.accepts 'json'
      res.send 'Not Authorized', 403

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

  @get '/playlists', -> requiresLogin @request, @response, =>
    client = getClient @request
    client.gs.request 'getUserPlaylists', {}, (err, status, body) =>
      return if handle_errors @request, err, status

      @send body

  @post '/login', ->
    client = new GroovesharkClient config.grooveshark_key, config.grooveshark_secret
    client.authenticate @body.username, @body.password, (err, status, body) =>
      return if handle_errors @request, err, status

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
          return if handle_errors @request, err, res.status

          if body.length is 0
            parse.createUser
              username: @body.username
              password: config.parse_user_password
              uploaded_files: []
            , (err, res, body, success) =>
              return if handle_errors @request, body, res.status
              @request.session.user.ptoken = body.sessionToken
              @redirect @body.redirect or '/'
          else
            parse.loginUser @body.username, config.parse_user_password
            , (err, res, body, success) =>
              if not handle_errors @request, body, res.status
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
    if @request.session.user
      file = @request.files.file
      s3Path = '/'+@request.session.user.name+'/'+shortid.generate()+'/'+file.name
      req = s3.putFile file.path, s3Path, 'x-amz-acl': 'public-read', (err, res) =>
        return if handle_errors @request, err, res.statusCode
        parse.sessionToken = @request.session.user.ptoken
        parse.updateUser @request.session.user.pid,
          uploaded_files:
            __op: 'Add'
            objects: [s3.url(s3Path)]
        , (err, res, body, success) =>
          return if handle_errors @request, err, res.statusCode
          @send 'success', 200
    else
      @send 'success', 200

config = require './config'
GroovesharkClient = require 'grooveshark'
zappa = require 'zappajs'
{exec} = require 'child_process'
JSON = require 'JSON'

exec 'cake build'

zappa.run config.port, ->
  clients = {}

  getClient = (req) ->
    return clients[req.session.user.id]


  handle_errors = (req, err, status) ->
    return false if not err

    if req.accepts 'html'
      for e in err
        req.session.errors.push
          msg: e.message
      return false
    else if req.accepts 'json'
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
    client.request 'getUserPlaylists', {}, (err, status, body) =>
      return if handle_errors @request, err, status

      @send body

  @post '/login', ->
    client = new GroovesharkClient config.grooveshark_key, config.grooveshark_secret
    client.authenticate @body.username, @body.password, (err, status, body) =>
      return if handle_errors @request, err, status

      if not client.authenticated
        @request.session.errors.push
          msg: 'Wrong username/password combination.'
      else
        @request.session.user =
          id: body.UserID
          name: @body.username
        clients[@request.session.user.id] = client

      @redirect @body.redirect or '/'

  @post '/logout', -> requiresLogin @request, @response, =>
    client = getClient @request
    if client
      client.logout (err, status, body) =>
        return if handle_errors(@request, err, status)
        delete clients[@request.session.user.id]

        @request.session.user = null
        @redirect @body.redirect or '/'

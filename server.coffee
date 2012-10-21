config = require './config'
GroovesharkClient = require 'grooveshark'
zappa = require 'zappajs'
{exec} = require 'child_process'
JSON = require 'JSON'

exec 'cake build'


zappa.run config.port, ->

  @use 'bodyParser',
    static: __dirname + '/public',
    'zappa',
    'partials',
    @express.cookieParser(),
    session: secret: 'watlol'

  @get '/', ->
    @render 'index',
      user: @request.session.user
      errors: @request.session.errors or []

    @request.session.errors = []

  @post '/login', ->
    client = new GroovesharkClient config.grooveshark_key, config.grooveshark_secret

    client.authenticate @body.username, @body.password, (err) =>
      if err
        console.error err
        for e in err
          console.log @request.connection
          @request.session.errors.push
            msg: e.message
            debug_info: JSON.stringify
              action: '/login'
              err: JSON.stringify err
      else
        console.log 'login successful as "' + @body.username + '"'
        @request.session.user =
          name: @body.username
        @request.session.gs = client

      @redirect @body.redirect or '/'

      ###
      client.request 'someMethod',
        param1: 'foobar'
        param2: 1234
      , (err, status, body) ->
        throw err  if err
        console.log body
      ###

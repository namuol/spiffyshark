doctype 5
html ->
  head ->
    meta charset:'utf-8'
    meta
      name:'viewport'
      content:'''width=device-width; 
              initial-scale=0.75;
              maximum-scale=0.75;
              minimum-scale=0.75; 
              user-scalable=no;'''
    meta name:'apple-mobile-web-app-capable', content:'yes'
    title @title

    link rel:'stylesheet', href:'bootstrap/css/bootstrap.css'
    link rel:'stylesheet', href:'bootstrap/css/bootstrap-responsive.css'
    link rel:'stylesheet', href:'style.css'

    coffeescript ->
      window.scripts = []

  body ->
    if @user
      input id:'username', type:'hidden', value:''+@user.name
    div id:'top', ->
      div class:'navbar container', ->
        div class:'navbar-inner', ->
          span id:'breadcrumb', class:'brand', ->
            a href:'#/', 'Spiffyshark'
            span class:'divider', '/'
            a href:'#/playlists', 'playlists'

          div id:'account-nav-container', ->
            if not @user
              div class:'navbar-text pull-right', ->
                a id:'show_login_form', href:'#', 'Log In'
              form
                class:'navbar-form pull-right'
                id:'log-in'
                action:'login'
                method:'post'
              , ->
                input
                  id:'log-in-username'
                  autocomplete:'false'
                  name:'username'
                  placeholder:'Grooveshark Username'
                  type:'text'
                  class:'span2'
                text '&nbsp;'
                input
                  id:'log-in-pass'
                  name:'password'
                  placeholder:'Password'
                  type:'password'
                  class:'span2'
                text '&nbsp;'
                button type:'submit', class:'btn btn-primary pull-right', 'Log In'

            if @user
              form
                action:'logout'
                method:'post'
                class:'navbar-form pull-right'
              , ->
                a
                  id:'user_button'
                  href:'#/playlists'
                  class:'btn btn-clear'
                , ->
                  i class:'icon-white icon-user'
                  span id:'username-display', " #{@user.name}"
                text '&nbsp;'
                button
                  id:'log-out'
                  class:'btn btn-clear'
                  type:'submit'
                , 'Log Out'
      div class:'container', ->
        div class:'row', ->
          div id:'msgs', class:'errors_list'
          if @errors.length > 0
            for err in @errors
              div class:'alert alert-error fade in', 'data-debug-info':err.debug_info, ->
                button type:'button', class:'close', 'data-dismiss':'alert', '×'
                strong 'error: '
                text err.msg

      div id:'brand_row', class:'row content', ->
        h1 id:'main_brand', ->
          text 'Spiffyshark'
          sup class:'alpha', ->
            span
              rel:'tooltip'
              'data-original-title':'Very early preview; expect bugs!'
              'data-placement': 'bottom'
            , -> 'prealpha'
        h2 id:'slogan', ->
          text 'Better '
          span class:'grooveshark_logo_text', ->
            span 'Grooveshark'
          text ' Playlists'

    div id:'content', class:'container', ->

      text @body

    script src:'/coffeecup.js'
    script src:'//cdnjs.cloudflare.com/ajax/libs/jquery/1.8.2/jquery.min.js'
    script src:'//cdnjs.cloudflare.com/ajax/libs/moment.js/1.7.2/moment.min.js'
    script src:'/zappa/zappa.js'
    script src:'/zappa/sammy.js'
    script src:'/socket.io/socket.io.js'
    script src:'/async.js'
    script src:'/xspf_parser.js'
    script src:'/bootstrap/js/bootstrap.js'
    script src:'/jquery-ui-1.9.1.custom.js'
    
    coffeescript ->
      Array::remove = (from, to) ->
        rest = @slice((to or from) + 1 or @length)
        @length = (if from < 0 then @length + from else from)
        @push.apply this, rest

      $('[rel=tooltip][data-original-title]').tooltip()

      for script in window.scripts
        script()

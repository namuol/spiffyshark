doctype 5
html ->
  head ->
    meta charset:'utf-8'
    meta name:'apple-mobile-web-app-capable', content:'yes'
    title @title

    link rel:'stylesheet', href:'bootstrap/css/bootstrap.css'
    link rel:'stylesheet', href:'style.css'
    link rel:'stylesheet', href:'bootstrap/css/bootstrap-responsive.css'

    coffeescript ->
      window.scripts = []

  div class:'navbar navbar-inverse navbar-fixed-top', ->
    div class:'navbar-inner', ->
      div class:'container-fluid', ->
        a href:'#/', class:'brand', 'Spiffyshark'
        div class:'', ->
          ul class:'nav', ->
            if @user
              li -> a href:'#/playlists', ->
                i class:'icon-white icon-list'
                text ' Playlists'
            li -> a href:'#/help', ->
              i class:'icon-white icon-question-sign'
              text ' Help'

          div id:'account-nav-container', ->
            if not @user
              ul id:'log-in-nav', class:'nav pull-right', ->
                li class:'dropdown', ->
                  a href:'#',
                    role:'button',
                    class:'dropdown-toggle',
                    'data-toggle':'dropdown'
                  , ->
                    text 'Log In '
                    b class:'caret', ''

                  div class:'dropdown-menu', role:'menu', ->
                    form id:'log-in', action:'login', method:'post', ->
                      div class:'control-group', ->
                        div class:'controls', ->
                          div class:'input-prepend', ->
                            span class:'add-on', ->
                              i class:'icon-user'
                            input
                              id:'log-in-username'
                              name:'username'
                              type:'text'
                              placeholder:'Grooveshark Username'

                        div class:'controls', ->
                          div class:'input-prepend', ->
                            span class:'add-on', ->
                              i class:'icon-lock'
                            input
                              id:'log-in-pass'
                              name:'password'
                              type:'password'
                              placeholder:'Password'
                        button class:'btn pull-right', 'Log In'

            if @user
              ul id:'account-nav', class:'nav pull-right', ->
                li class:'dropdown', ->
                  a href:'#',
                    role:'button',
                    class:'dropdown-toggle',
                    'data-toggle':'dropdown'
                  , ->
                    i class:'icon-white icon-user'
                    span id:'username-display', " #{@user.name} "
                    b class:'caret', ''

                  ul class:'dropdown-menu', role:'menu', ->
                    ###
                    li -> a href:'#subscriptions', ->
                      i class:'icon-shopping-cart'
                      text ' Subscriptions'
                    li -> a href:'#billing', ->
                      i class:'icon-list-alt'
                      text ' Billing History'
                    ###
                    li ->
                      form action:'logout', method:'post', ->
                        button
                          id:'log-out'
                          class:'btn pull-right'
                          type:'submit'
                        , 'Log Out'

  div id:'content', class:'container', ->
    div class:'row-fluid', ->
      div id:'msgs', class:'errors_list span6'
      if @errors.length > 0
        for err in @errors
          div class:'alert alert-error fade in', 'data-debug-info':err.debug_info, ->
            button type:'button', class:'close', 'data-dismiss':'alert', '×'
            strong 'error: '
            text err.msg

    div class:'content', id:'main', ->

      div class:'row', ->
        div class:'span6', ->
          h1 id:'main_brand', ->
            text 'Spiffyshark'

      div class:'row', ->
        div class:'span4', ->
          p """
          Upload your playlist to Grooveshark.
          """
        div class:'span6', ->
          div class:'input-append', ->
            form id:'upload', enctype:'multipart/form-data', action:'#/upload_playlist', method:'post', ->
              input type:'file'
              button
                type:'submit'
                class:"btn btn-primary"
                href:'#how-it-works'
                , 'Upload'

    text @body

    script src:'/coffeecup.js'
    script src:'//code.jquery.com/jquery.js'
    script src:'//cdnjs.cloudflare.com/ajax/libs/moment.js/1.7.2/moment.min.js'
    script src:'/zappa/zappa.js'
    script src:'/zappa/sammy.js'
    script src:'/socket.io/socket.io.js'
    script src:'/async.js'
    script src:'/xspf_parser.js'
    script src:'/bootstrap/js/bootstrap.js'

    coffeescript ->
      for script in window.scripts
        script()

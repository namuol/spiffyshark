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
    title 'Spiffyshark: Better Grooveshark Playlists'

    link rel:'stylesheet', href:'bootstrap/css/bootstrap.css'
    link rel:'stylesheet', href:'bootstrap/css/bootstrap-responsive.css'
    link rel:'stylesheet', href:'style.css'

    coffeescript ->
      window.scripts = []

  body ->
    # SOCIAL:
    text '''
    <div id="fb-root"></div>
    <script>(function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) return;
      js = d.createElement(s); js.id = id;
      js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=305537439554846";
      fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));</script>

    '''

    div id:'all', ->
      if @user
        username = @user.name
      else
        username = ''

      input id:'username', type:'hidden', value:username
      div id:'top', ->
        div class:'navbar container', ->
          div class:'navbar-inner', ->
            span id:'breadcrumb', class:'brand', ->
              a href:'#/', 'Spiffyshark'
              span class:'divider', '/'
              a href:'#/playlists', 'playlists'

            div id:'account-nav-container', ->
              div class:'logged-out navbar-text pull-right', ->
                button class:'btn btn-clear', id:'show_login_form', 'Log In'
              form
                class:'navbar-form pull-right'
                id:'log-in'
                action:'login'
                method:'post'
              , ->
                div class:'logged-out', ->
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
                  #text '&nbsp;'
                  button type:'submit', class:'btn btn-clear pull-right', 'Log In'

              form
                id:'log-out'
                action:'logout'
                method:'post'
                class:'navbar-form pull-right'
              , ->
                div class:'logged-in', ->
                  a
                    id:'user_button'
                    href:'#/playlists'
                    class:'btn btn-clear'
                  , ->
                    i class:'icon-white icon-user'
                    text ' '
                    span class:'username-display', username
                  text '&nbsp;'
                  button
                    id:'log-out-button'
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

      footer class:'footer', ->
        div class:'container', ->
          p ->
            text '© 2012 '
            a target:'_blank', href:'//namuol.github.com/', 'Louis Acresti'
          ul class:'nav nav-pills', ->
            li ->
              a href:'#/about', 'About'
            li ->
              a href:'#/faq', 'FAQ'
            li ->
              a href:'//blog.spiffyshark.com', 'Blog'
            li ->
              a href:'//twitter.com/spiffyshark', 'Twitter'
            li ->
              a href:'//facebook.com/spiffyshark', 'Facebook'
          div id:'social', ->
            text '''
            <fb:like href="http://facebook.com/spiffyshark" send="false" layout="button_count" width="80" show_faces="false" colorscheme="dark"></fb:like>
            '''
            ###text '''
<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://spiffyshark.com" data-text="Create better Grooveshark playlists with @Spiffyshark!">Tweet</a>
  <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
            '''
            ###

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
    script type:'text/javascript', ->
      text '''
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-36144867-1']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
      '''
    text '''
    '''

div class:'content container', id:'main', ->
  div id:'new_playlist_options_wrapper', ->
    div id:'new_playlist_options', class:'row', ->
      div id:'import', class:'row option', ->
        legend 'Import'
        form id:'upload', enctype:'multipart/form-data', action:'#/upload_playlist', method:'post', ->
          input id:'upload_file', type:'file'
        div id:'import_buttons', ->
          button id:'lastfm_main', class:'btn btn-lastfm'
          text ' '
          button class:'btn btn-inverse', id:'upload_btn', ->
            i class:'icon-file icon-white'
            b ' File'
      a id:'search', class:'row option', href:'#/search', ->
        legend 'Whole-Album'
        p 'Find all tracks with one click'
      a id:'create', class:'row option', href:'#/new_playlist', ->
        legend 'New Mix'
        p 'Create a playlist from scratch'


div class:'content container', id:'help', ->
  h2 'Help contents go here.'

div class:'content container', id:'about', ->
  section ->
    h2 'About'

    section ->
      h3 'Why use Spiffyshark?'
      p '''
      I created Spiffyshark because I was frustrated with the inability to easily import playlist files
      from other services like Last.fm into Grooveshark.
      '''
      p '''
      There were some <a href='//groovylists.com'>existing sites</a> out there that do this fairly well,
      but they lacked any ability to manually select songs or change the search terms when nothing can be
      found.
      '''
      p '''
      Grooveshark has a lot of content, but it's not always labeled very well. Spiffyshark finds the stuff
      you most likely want, and lets you manually select each song, if necessary.
      '''
      p '''
      Spiffyshark also acts as a powerful tool for creating and editing Grooveshark playlists from scratch.
      '''

    section ->
      h3 'Who are you?'
      p '''
      I'm Louis Acresti, a freelance programmer from Rochester, New York (soon to be in Austin, Texas).
      '''
      p '''
      I really love web development.
      '''
      p '''
      I also love cheese, homebrewing beer, and <a href='//last.fm/user/louman' target='_blank'>listening to music</a>, of course.
      '''
      p '''
      If you're looking for someone to work on an awesome project with, please <a href='mailto:louis.acresti@gmail.com' target='_blank'>contact me</a>.
      '''

div class:'content container', id:'faq', ->
  section ->
    h2 'FAQ'
    section ->
      h3 'Is it free?'
      p '''
      <b>Yes!</b> I aim to keep Spiffyshark a <b>completely</b> free service, with <b>no ads</b> getting in the way.
      '''
      p '''
      <i><a href='//youtube.com/watch?v=Pgd2w0SQEYI' target='_blank'>Having said that</a></i>, I pay for the hosting out of my pocket,
      so if you find the app useful, please consider making a small 
      <a href='#/thanks'>contribution</a>. Money goes toward hosting costs, site maintenance, and quality beer.
      '''
    section ->
      h3 'How are songs chosen?'
      p '''
      It chooses the best song based on a simple "score" model. Songs that most closely resemble your search
      terms are chosen.
      '''
      p '''
      The most important factors in the score are the title, and artist name. If an album is provided, it is the
      next most important search factor. Songs that provide artwork are also assumed to be slightly higher-quality.
      '''
      p '''
      Ties are broken when songs comes from "verified" Grooveshark users -- users that Grooveshark has flagged
      as providing high quality song files.
      '''
    section ->
      h3 'Do I need to log in?'
      p '''
      No. You can create "anonymous" playlists without logging in to your Grooveshark account. These playlists 
      are saved temporarily (for 24 hours) on Spiffyshark's own Grooveshark account.
      '''
      p '''
      If you do log in, your playlists will be exported to your own Grooveshark account, and will be stored
      permanently, so it is recommended.
      '''
      p '''"Anonymous" playlists can be saved permanently by re-saving them once logged in; a copy
      will be made, and you can safely delete the original Anonymous playlist.
      '''
    section ->
      h3 'What playlist formats can I import?'
      p '''
      Currently only <a href='//xspf.org'>XSPF</a> playlists are supported.
      '''
      p '''
      I plan on supporting M3U and iTunes library files in the future. If you have a format you'd like
      to see supported, <a href='mailto:louis.acresti@gmail.com'>let me know</a>!
      '''

div class:'content container', id:'thanks', ->
  section ->
    h2 'Say Thanks'
    p '''
    Spiffyshark is <b>completely free</b> to use. With no ads. That doesn't mean it's free to host!
    '''
    p '''
    Your small contribution goes a long way to keep the site running smoothly. It will also make you feel warm and fuzzy,
    and reaffirm my faith in humanity.
    '''

    form action:"https://checkout.google.com/api/checkout/v2/checkoutForm/Merchant/211159781209062", id:"BB_BuyButtonForm", method:"post", name:"BB_BuyButtonForm", target:"_top", ->
      input name:"item_name_1", type:"hidden", value:"Spiffyshark Supporter"
      input name:"item_description_1", type:"hidden", value:""
      input name:"item_quantity_1", type:"hidden", value:"1"
      input name:"item_currency_1", type:"hidden", value:"USD"
      input name:"_charset_", type:"hidden", value:"utf-8"
      div class:'input-prepend input-append', ->
        span class:'add-on currency', 'USD $'
        input id:'buy-now-amt', name:"item_price_1", type:"text", value:"5.00"
        span id:'buy-now-wrap', class:'add-on', ->
          input alt:"", src:"https://checkout.google.com/buttons/buy.gif?merchant_id=211159781209062&amp;w=117&amp;h=48&amp;style=trans&amp;variant=text&amp;loc=en_US", type:"image"

    section ->
      h3 'Other Ways to Say Thanks'
      ul ->
        li ->
          a href:'//facebook.com/spiffyshark', 'Like the Facebook page'
        li ->
          a href:'//twitter.com/spiffyshark', 'Follow @spiffyshark'
        li ->
          a href:'mailto:louis.acresti@gmail.com', 'Tell me that you use the app'

div class:'content container', id:'playlists', ->
  ###
  div class:'span5', ->
    legend ->
      text 'Your Grooveshark Playlists'
    i class:'icon-refresh animooted'
    ul id:'gs_playlists_list', class:'playlists_list'
  ###
  legend ->
    span class:'logged-in', ->
      span class:'username-display'
      text '\'s '
    text 'Playlists'
    span class:'logged-out', ->
      text ' From This Device'
    a href:'#/new_playlist', class:'btn btn-clear', ->
      i class:'icon-plus icon-white'
  ul id:'xspf_playlists_list', class:'playlists_list'

div id:'playlist_loading', class:'content container', ->
  i class:'icon-refresh icon-white animooted'
  text ' Loading Playlist...'

div class:'content', id:'playlist', ->
  div class:'row', ->
    legend ''

  div id:'playlist_top_wrapper', ->
    div id:'playlist_top', class:'row', ->
      div class:'btn-toolbar',->
        div id:'add_song_group', class:'btn-group', ->
          button id:'add_song', class:'btn btn-success btn-large', ->
            i class:'icon-plus icon-white'
            span ' Add'
          button class:'btn btn-success btn-large dropdown-toggle', 'data-toggle':'dropdown', ->
            span class:'caret'
          ul class:'dropdown-menu', ->
            li ->
              #i class:'icon-search'
              a id:'add_album', tabindex:-1, href:'#', 'Album...'
            li ->
              a id:'add_lastfm', tabindex:-1, href:'#', 'Last.fm...'

        button id:'del_song', class:'btn btn-danger btn-large', disabled:'disabled', ->
          i class:'icon-trash icon-white'
          span ' Delete'
        div id:'search_songs_wrap', class:'btn-group', ->
          button
            id:'search_songs'
            class:'btn btn-primary btn-large'
          , ->
            i class:'icon-search icon-white'
            span ' Search'
          button id:'search_dropdown_toggle', class:'btn btn-primary btn-large dropdown-toggle', 'data-toggle':'dropdown', ->
            span class:'caret'
          ul class:'dropdown-menu', ->
            li ->
              a id:'search_all_songs', tabindex:-1, href:'#', '...and Replace <b>all</b>'
        div id:'cancel_search_songs_wrap', class:'btn-group', ->
          button id:'cancel_search_songs', class:'btn btn-warning btn-large', ->
            i class:'icon-remove icon-white'
            span ' Cancel'
          button class:'btn btn-warning btn-large dropdown-toggle', 'data-toggle':'dropdown', disabled:'disabled', ->
            span class:'caret'
          ul class:'dropdown-menu'

        text '&nbsp;'
        button
          id:'save_playlist'
          class:'btn btn-inverse btn-large'
          'data-loading-text':"<i class='icon-refresh icon-white animooted'></i><span> Saving</span>"
          'data-saved-text':"<i class='icon-ok icon-white'></i><span> Saved</span>"
        , ->
          i class:'icon-download-alt icon-white'
          span ' Save'
        text '&nbsp;'
        button id:'show_gs_playlist', class:'btn btn-inverse btn-large', ->
          text '&nbsp;'
        br ''
        strong id:'disconnected_msg', 'Uh oh! Connection lost. Try refreshing the page.'

  div class:'row', ->
    table class:'uploaded_playlist table table-condensed table-striped', ->
      thead ->
        tr ->
          th colspan:'0', ''
          th 'Playlist Track (Search Terms)'
          th 'Grooveshark Track (Search Results)'
      tbody id:'playlist_items', ''

div id:'album_search_modal', class:'modal hide', ->
  div class:'modal-header', ->
    button
      type:'button'
      class:'close'
      'data-dismiss':'modal'
      'aria-hidden':'true'
    , -> text '&times'

    h3 'Add an Album\'s Tracks'

  div class:'modal-body', ->
    form class:'form-horizontal', ->
      div class:'control-group', ->
        label class:'control-label', for:'creator', 'Artist'
        div class:'controls', ->
          input class:'input-xlarge', type:'text', name:'artist'
      div class:'control-group', ->
        label class:'control-label', for:'title', 'Album Title'
        div class:'controls', ->
          input class:'input-xlarge', type:'text', name:'title'
      div class:'control-group', ->
        div class:'controls', ->
          button type:'submit', class:'btn btn-primary', ->
            strong 'Search'

      div id:'album_modal_search_results'

div id:'lastfm_modal', class:'modal hide', ->
  div class:'modal-header', ->
    button
      type:'button'
      class:'close'
      'data-dismiss':'modal'
      'aria-hidden':'true'
    , -> text '&times'

    h3 'Add Last.fm Tracks'

  div class:'modal-body', ->
    form class:'form-horizontal', ->
      div class:'control-group', ->
        label class:'control-label', for:'user', 'Username'
        div class:'controls', ->
          input class:'input-xlarge', type:'text', name:'user'
      div class:'control-group', ->
        div class:'controls', ->
          button class:'btn btn-primary', type:'submit', 'Load Last.fm Playlists'
      div id:'lastfm_results'

div id:'song_modal', class:'modal hide', ->

coffeescript ->
  window.scripts.push ->
    window.gs_songs_rel = 's'
    window.gs_playlist_rel = 'p'

    song_modal_template = coffeecup.compile ->
      div class:'modal-header', ->
        button
          type:'button'
          class:'close'
          'data-dismiss':'modal'
          'aria-hidden':'true'
        , -> text '&times'

        h3 'Edit Song Details'

      div class:'modal-body', ->
        form class:'form-horizontal', ->
          div class:'control-group', ->
            label class:'control-label', for:'creator', 'Artist'
            div class:'controls', ->
              input class:'input-xlarge', type:'text', name:'creator', value:@creator
          div class:'control-group', ->
            label class:'control-label', for:'title', 'Title'
            div class:'controls', ->
              input class:'input-xlarge', type:'text', name:'title', value:@title
          div class:'control-group', ->
            label class:'control-label', for:'title', 'Album'
            div class:'controls', ->
              input class:'input-xlarge', type:'text', name:'album', value:@album
          div class:'control-group', ->
            div class:'controls', ->
              button id:'song_modal_search', type:'submit', class:'btn btn-primary', ->
                strong 'Search'

          div class:'modal_search_results'

    grooveshark_playlist_link_modal_template = coffeecup.compile ->
      div class:'modal hide grooveshark_playlist_link_modal', ->
        div class:'modal-body', ->
          h4 'Success!'
          p 'Click the link below to view your shiny new playlist!'
          div class:'well well-small', ->
            a class:'grooveshark_playlist_link', href:@url, target:'grooveshark', ->
              text @url
          p ->
            text 'Like Spiffyshark? '
            a href:'#/thanks', target:'_blank', 'Say Thanks!'

    song_modal_search_results_template = coffeecup.compile ->
      track_info = (song, index, chosen) ->
        btn_class = 'select-song btn'
        if song.selected
          btn_class += ' active'
          if chosen
            btn_class += ' chosen'
        button class:btn_class, 'data-toggle':'button', 'data-gs-song-index':''+index, ->
          i class:'icon-ok'
        div class:'track_info', 'data-gs-song-index':index, ->
          text ' '
          img class:'album_art', src:"http://images.grooveshark.com/static/albums/40_#{song.CoverArtFilename or 'album'}"
          div class:'track_title', ->
            a href:"/gs_song/#{song.SongID}", target:'grooveshark', ->
              text ' ' + song.SongName
          div class:'track_artist_album', ->
            a href:"/gs_artist/#{song.ArtistID}", target:'grooveshark', ->
              text song.ArtistName
            text ' • '
            a href:"/gs_album/#{song.AlbumID}", target:'grooveshark', ->
              text song.AlbumName
          div class:'score', ->
            text song.score or 0
            cls = 'icon-ok'
            if song.IsVerified in [true, "true"]
              cls += ' verified'
            i class:cls

      @extension = @extension or {}
      songs = @extension[gs_songs_rel]
      if not songs?
        return
      
      if songs.length is 0
        text 'No songs found :('
        return

      ul class:'search_results', ->
        idx = 0
        for song in songs
          li ->
            track_info song, idx, @chosen
          ++idx

    album_modal_search_results_template = coffeecup.compile ->
      if @results.length is 0
        text 'Nothing found.'
        return
      ul class:'search_results', ->
        for master in @results
          split = master.title.split(' - ')
          artist = split[0]
          title = split[1]
          li
            class:'discogs_master'
            'data-url':master.resource_url
            'data-thumb':master.thumb
            'data-artist':artist
            'data-album':title
          , ->
            div class:'show_discogs_master', ->
              i class:'icon-chevron-right'
            div class:'hide_discogs_master', ->
              i class:'icon-chevron-down'
            div class:'track_info', ->
              text ' '
              img class:'album_art', src:''
              div class:'track_title', ->
                text title
              div class:'track_artist_album', ->
                text artist
                if master.label? and master.label.length > 0
                  text ' • '
                  text master.label[0]
                if master.year?
                  text ' • '
                  text master.year
            button class:'btn btn-success add_album_tracks', ->
              i class:'icon-plus icon-white'
            div class:'discogs_master_result'

    discogs_master_result_template = coffeecup.compile ->
      div class:'well well-small', ->
        div class:'discogs_thumb', ->
          img src:@thumb
        text 'Tracklist:'
        ul class:'discogs_tracklist', ->
          for track in @tracklist
            li ->
              text track.position
              text '. '
              text track.title

    lastfm_results_template = coffeecup.compile ->
      if @playlists.playlist.length is 0
        text 'Nothing found.'
        return

      ul class:'search_results', ->
        for playlist in @playlists.playlist
          li
            class:'discogs_master'
            'data-id':playlist.id
            'data-creator':playlist.creator.replace('http://www.last.fm/user/','')
            'data-title':playlist.title
          , ->
            div class:'show_lastfm_playlist', ->
              i class:'icon-chevron-right'
            div class:'hide_lastfm_playlist', ->
              i class:'icon-chevron-down'
            div class:'track_info', ->
              text ' '
              img class:'album_art', src:''
              div class:'track_title', ->
                text playlist.title
              div class:'track_artist_album', '&nbsp;'
            button class:'btn btn-success add_lastfm_playlist_tracks', ->
              i class:'icon-plus icon-white'
            div class:'lastfm_playlist_result'

    lastfm_playlist_result_template = coffeecup.compile ->
      div class:'well well-small', ->
        #div class:'discogs_thumb', ->
        #  img src:@thumb
        text 'Tracklist:'
        ol class:'discogs_tracklist', ->
          for track in @playlist.trackList.track
            li ->
              text track.creator
              text ' - '
              text track.title

    playlist_row_template = coffeecup.compile ->
      @track = @track or {}
      @track.extension = @track.extension or {}
      songs = @track.extension[gs_songs_rel]
      if songs?
        for s in songs
          if s.selected
            song = s
      if not (song?) and (songs?)
        row_class = 'no_songs_found'
      else
        row_class = ''

      tr class:row_class, ->
        td class:'buttons', ->
          button class:'btn editTrack', -> i class:'icon-pencil'

        td class:'playlist', ->
          div class:'track_info', ->
            div class:'track_title', ->
              @track.title = @track.title or ''
              text @track.title
            div class:'track_artist_album', ->
              @track.creator = @track.creator or ''
              text @track.creator
              @track.album = @track.album or ''
              if @track.album
                text " • #{@track.album}"

        td class:'gs', ->
          div class:'track_info',  ->
            if not song?
              if songs?
                text 'None Found :('
              return
            text ' '
            img class:'album_art', src:"http://images.grooveshark.com/static/albums/40_#{song.CoverArtFilename or 'album'}"
            div class:'track_title', ->
              a href:"/gs_song/#{song.SongID}", target:'grooveshark', ->
                text ' ' + song.SongName
            div class:'track_artist_album', ->
              a href:"/gs_artist/#{song.ArtistID}", target:'grooveshark', ->
                text song.ArtistName
              text ' • '
              a href:"/gs_album/#{song.AlbumID}", target:'grooveshark', ->
                text song.AlbumName
          if not song?
            return
          div class:'score', ->
            text song.score or 0
            cls = 'icon-ok'
            if song.IsVerified in [true, "true"]
              cls += ' verified'
            i class:cls

    gs_playlist_row_template = coffeecup.compile ->
      li 'data-playlist-id':@PlaylistID, ->
        text @PlaylistName

    xspf_playlist_row_template = coffeecup.compile ->
      li 'data-playlist-id':@id, 'data-local':''+@local?, ->
        button 'data-id':''+@id, class:'del_playlist btn btn-clear', ->
          i class:'icon-trash icon-white'
        a href:'#/playlist/'+@id, ->
          if @local
            span
              class:'label label-important pull-right',
              rel:'tooltip'
              'data-original-title':'Save this playlist when logged in to associate it with your Grooveshark account.'
              'data-placement': 'left'
            , -> 'Anonymous'
            text ' '
          if @creator
            text @creator + ' - '
          text @title
          text " (#{@track_count} songs)"

    error_template = coffeecup.compile ->
      div class:'alert alert-error fade in', 'data-debug-info':@msg.debug_info, ->
        button type:'button', class:'close', 'data-dismiss':'alert', '×'
        strong 'Error: '
        text @msg.msg

    alert_template = coffeecup.compile ->
      div class:'alert fade in', 'data-debug-info':@msg.debug_info, ->
        button type:'button', class:'close', 'data-dismiss':'alert', '×'
        strong 'Warning: '
        text @msg.msg

    playlist_legend_template = coffeecup.compile ->
      span id:'playlist_title', contenteditable:'true', spellcheck:'false', @title
      text ' by '
      span id:'playlist_creator', contenteditable:'true', spellcheck:'false', @creator

    $ ->
      logged_in = false
      user_id = undefined
      update_username = (username) ->
        $('.username-display').text username
        if username? and username != ''
          logged_in = true
          $('.logged-out').hide()
          $('.logged-in').show()
        else
          logged_in = false
          $('.logged-in').hide()
          $('.logged-out').show()

      update_username($('#username').val())

      addMsg = (msg) ->
        ###
        if not msg.transient
          messages = JSON.parse(localStorage.getItem('messages')) or []
          messages.push msg
          localStorage.setItem 'messages', JSON.stringify messages
        ###
        renderMsg msg

      addExpiresMsg = (expires) ->
        addMsg
          transient: true
          type: 'alert'
          msg:"""Since you are not logged in, this playlist file expires <strong>#{moment(expires).fromNow()}</strong>.
          <br/>
          Log in with your Grooveshark account, and you can:
          <ul>
            <li>Keep your playlist files here permanently.
            <li>Export your playlist files to Grooveshark playlists.
          </ul>
          """

      renderMsg = (msg) ->
        switch msg.type
          when 'error'
            el = $(error_template(msg: msg))
          when 'alert'
            el = $(alert_template(msg: msg))

        $('#msgs').prepend el
        ###
        el.find('button.close').click ->
          messages = JSON.parse(localStorage.getItem('messages')) or []
          messages.remove $(@).parent().index()
          localStorage.setItem 'messages', JSON.stringify messages
        ###
      ###
      messages = JSON.parse(localStorage.getItem('messages')) or []
      for msg in messages
        renderMsg msg
      ###

      $('#show_login_form').click ->
        $(@).hide()
        $('#log-in').show()
        $('#log-in input').first().focus()
        return false

      hide_login = true
      $('#log-in').live 'blur', (e) ->
        hide_login = true
        setTimeout =>
          if hide_login
            $(@).hide()
            $('#show_login_form').show()
        , 250

      $('#log-in').live 'focus', (e) ->
        hide_login = false
        setTimeout =>
          if hide_login
            $('#show_login_form').hide()
            $(@).show()
        , 250
      $('#log-in').submit (e) ->
        e.preventDefault()

        hide_login = false

        $(@).find('button').button 'loading'
        $(@).find('input').attr 'disabled', 'disabled'

        $.ajax
          type: 'POST'
          url: '/login'
          data:
            username: $('#log-in-username').val()
            password: $('#log-in-pass').val()
        .success (data) =>
          user_id = data.user_id
          s.emit 'user_id', user_id
          update_username($('#log-in-username').val())
        .error (data) =>
          $(@).parent().show()
        .complete =>
          $(@).find('button').button 'reset'
          $(@).find('input').val('').attr 'disabled', false

        return false

      $('#log-out').submit (e) ->
        e.preventDefault()

        $(@).find('button').button 'loading'
        $(@).find('input').attr 'disabled', 'disabled'

        $.ajax
          type: 'POST'
          url: '/logout'
        .success (data) =>
          user_id = undefined
          s.emit 'user_id', user_id
          update_username('')
          app.setLocation '#/'
          $('#xspf_playlists_list').html ''
        .error (data) =>
          $(@).parent().show()
        .complete =>
          $(@).find('button').button 'reset'

        return false

      animooted = '<i class="icon-refresh animooted"></i>'
      animooted_white = '<i class="icon-refresh icon-white animooted"></i>'

      $.fn.button.defaults.loadingText = ->
        animooted_white + ' loading...'
      
      playlistDirtied = =>
        change = window.lastChange = new Date
        window.playlistDirty = true
        $('#save_playlist').button 'reset'
        setTimeout ->
          return
          return if not window.playlistDirty
          if lastChange - change is 0
            $('#save_playlist').click()
        , 5000

      playlistSaved = =>
        window.playlistDirty = false
        $('#save_playlist').button 'saved'
        setTimeout ->
          $('#save_playlist').attr 'disabled', 'disabled'
        , 20

      jspf = {}
      playlist_id = null

      connected = false

      s = io.connect()

      s.on 'connect', ->
        $('#disconnected_msg').hide()
        connected = true
        s.emit 'user_id', 

      s.on 'disconnect', ->
        $('#disconnected_msg').show()
        connected = false

      app = new Sammy ->
        getSong = (i, cb, updateModal=false) ->
          el = $($('.uploaded_playlist tbody tr')[i])
          el.find('button.getSong').attr('disabled','disabled').html animooted
          el.find('td.gs').html animooted

          if updateModal
            $('#song_modal .modal_search_results').html animooted

          track = jspf.playlist.track[i]
          s.emit 'song',
            creator: track.creator
            title: track.title
            album: track.album
          , (data) ->
            if data.err
              el.find('td.gs').html 'Error!'
              cb null if cb?
              return

            ext = track.extension[gs_songs_rel] or []

            if not track.chosen
              playlistDirtied()
              ext = []
            else
              chosen = undefined
              for song in ext
                if song.selected? and song.selected
                  chosen = song
                  break
              ext = [chosen]

            for song in data.songs
              if chosen?
                if (''+song.SongID is ''+chosen.SongID)
                  continue
                delete song.selected

              ext.push song

            track.extension[gs_songs_rel] = ext

            newRow = playlist_row_template index:i, track:track

            el.replaceWith newRow
            if updateModal
              window.selectedRow = $('.uploaded_playlist tbody tr')[i]
              $('#song_modal .modal_search_results').html song_modal_search_results_template track

            cb null if cb?

        hasChosen = (idx) ->
          jspf.playlist.track[idx].chosen is true

        hasSearched = (idx) ->
          ext = jspf.playlist.track[idx].extension[gs_songs_rel]
          return ext?

        window.playlistDirty = false
        window.lastChange = new Date

        window.onbeforeunload = (e) ->
          if window.playlistDirty
            return e.returnValue = 'Your playlist has unsaved changes!'
          return null
        
        previousLocation = null
        confirmDialogShown = false
        @before {}, ->
          if confirmDialogShown
            confirmDialogShown = false
            return true

          ret = true
          if window.playlistDirty
            confirmDialogShown = true
            if not confirm 'Your playlist has unsaved changes! Are you sure you want to leave?'
              ret = false
              app.setLocation previousLocation
            else
              window.playlistDirty = false
          previousLocation = app.getLocation()
          return ret

        $('#content').ajaxError (e, xhr, settings, thrown) =>
          try
            resp = $.parseJSON xhr.responseText
          catch e
            resp = {}

          switch typeof resp.err
            when 'undefined'
              msg = thrown
            when 'string'
              msg = resp
            when 'object'
              if resp.err.msg
                msg = resp.err.msg
              else
                msg = 'Unexpected Error'
            else
              msg = 'Unexpected Error'

          addMsg
            transient: true
            type: 'error'
            msg: msg

        #$('#user_button').click (e) ->
        #  e.preventDefault()
        #  app.setLocation '#/playlists'
        #  return false

        $('#playlist_title').live 'blur', ->
          old = jspf.playlist.title
          _new = $('#playlist_title').text()
          if old != _new
            jspf.playlist.title = _new
            playlistDirtied()

        $('#playlist_creator').live 'blur', ->
          old = jspf.playlist.creator
          _new = $('#playlist_creator').text()
          if old != _new
            jspf.playlist.creator = _new
            playlistDirtied()

        $('#playlist_creator, #playlist_title').live 'keydown', (e) ->
          if e.which is 13
            $(@).blur()

        searching = false
        searches_break = false

        $('#cancel_search_songs').live 'click', (e) ->
          e.preventDefault()
          searches_break = true
          return false
        $('#cancel_search_songs_wrap').hide()

        $('#search_songs').live 'click', (e) ->
          $('#cancel_search_songs_wrap').show()
          $('#search_songs_wrap').hide()
          searching = true
          searches_break = false
          async.forEachLimit $('.uploaded_playlist tbody tr'), 2, (el, cb) =>
            if searches_break
              cb 'break'
              return

            if hasSearched $(el).index()
              cb null
              return

            i = $(el).index()
            getSong i, cb
          , (err) =>
            $('#cancel_search_songs_wrap').hide()
            $('#search_songs_wrap').show()
            searching = false

        $('#add_song').live 'click', (e) ->
          track =
            creator: ''
            title: ''
            album: ''
            extension: {}
          idx = (jspf.playlist.track.push track) - 1
          $('#playlist_items').append playlist_row_template
            track: track
            index: idx
            
          $('#playlist_items tr').last().find('button.editTrack').click()
          $('table tbody').sortable 'refresh'
          playlistDirtied()

        update_del_song_button = ->
          if $('#playlist_items tr.selected').toArray().length > 0
            $('#del_song').attr 'disabled', false
          else
            $('#del_song').attr 'disabled', 'disabled'

        $('#playlist_items tr td').live 'click', (e) ->
          $(@).parent().toggleClass 'selected'
          update_del_song_button()

        $('#add_album').live 'click', (e) ->
          $('#album_search_modal').modal()
          return false

        $('#album_search_modal form').on 'submit', (e) ->
          e.preventDefault()
          $('#album_modal_search_results').html animooted

          $.getJSON 'http://api.discogs.com/database/search?callback=?',
            type: "master"
            artist: $("form input[name=artist]").val()
            title: $("form input[name=title]").val()
          , (res, status, xhr) ->
            unless res.meta.status is 200
              console.err res
              $('#album_modal_search_results').html "Unexpected Error"
              return
            $('#album_modal_search_results').html album_modal_search_results_template res.data

          return false

        $('.show_discogs_master').live 'click', (e) ->
          el = $(@)
          el.hide()
          el.siblings('.hide_discogs_master').show()
          result_el = el.parent().find('.discogs_master_result').show()
          if not el.data('loaded') is true
            result_el.html animooted
            $.getJSON el.parent().data('url') + '?callback=?'
            , (res, status, xhr) =>
              unless res.meta.status is 200
                console.err res
                result_el.html "Unexpected Error"
                return
              el.data('loaded', true)
              res.data.thumb = el.parent().data('thumb')
              result_el.html discogs_master_result_template res.data
          return false

        $('.hide_discogs_master').live 'click', (e) ->
          $(@).hide()
          $(@).siblings('.show_discogs_master').show()
          $(@).parent().find('.discogs_master_result').hide()
          return false

        $('.add_album_tracks').live 'click', (e) ->
          if jspf.playlist.track.length is 0
            creator = $(@).parent().data 'artist'
            title = $(@).parent().data 'album'
            jspf.playlist.creator = creator
            jspf.playlist.title = title
            $('#playlist legend').html playlist_legend_template jspf.playlist

          $(@).button 'loading'
          $.getJSON $(@).parent().data('url') + '?callback=?'
          , (res, status, xhr) =>
            $(@).button 'reset'
            unless res.meta.status is 200
              console.err res
              alert "Unexpected Error"
              return
            creator = $(@).parent().data 'artist'
            album = $(@).parent().data 'album'
            for track in res.data.tracklist
              $.extend track,
                creator: creator
                album: album
                extension: {}
              idx = (jspf.playlist.track.push track) - 1
              $('#playlist_items').append playlist_row_template
                track: track
                index: idx
              track.idx = idx
              $('#playlist_items').sortable 'refresh'

            $('#search_songs').click()

            $('#album_search_modal').modal 'hide'
          return false
 
        $('#add_lastfm').live 'click', (e) ->
          $('#lastfm_modal').modal()
          return false

        $('#lastfm_modal form').on 'submit', (e) ->
          e.preventDefault()

          $('#lastfm_results').html animooted
          username = $("#lastfm_modal form input[name=user]").val()
          $.getJSON '/lfm_playlists/' + username
          , (res, status, xhr) ->
            #TODO HANDLE ERRORS
            $('#lastfm_results').html lastfm_results_template res

          return false
       
        $('.show_lastfm_playlist').live 'click', (e) ->
          el = $(@)
          el.hide()
          el.siblings('.hide_lastfm_playlist').show()
          result_el = el.parent().find('.lastfm_playlist_result').show()
          if not el.data('loaded') is true
            result_el.html animooted
            $.getJSON '/lfm_playlist/' + el.parent().data('id')
            , (res, status, xhr) =>
              #TODO HANDLE ERRORS
              el.data('loaded', true)
              console.log res
              result_el.html lastfm_playlist_result_template res
          return false

        $('.hide_lastfm_playlist').live 'click', (e) ->
          $(@).hide()
          $(@).siblings('.show_lastfm_playlist').show()
          $(@).parent().find('.lastfm_playlist_result').hide()
          return false
       
        $('.add_lastfm_playlist_tracks').live 'click', (e) ->
          if jspf.playlist.track.length is 0
            creator = $(@).parent().data 'creator'
            console.log creator
            title = $(@).parent().data 'title'
            jspf.playlist.creator = creator
            jspf.playlist.title = title
            $('#playlist legend').html playlist_legend_template jspf.playlist

          $.getJSON '/lfm_playlist/' + $(@).parent().data('id')
          , (res, status, xhr) =>
            $(@).button 'reset'
            for track in res.playlist.trackList.track
              idx = (jspf.playlist.track.push track) - 1
              $('#playlist_items').append playlist_row_template
                track: track
                index: idx
              track.idx = idx
              $('#playlist_items').sortable 'refresh'

            $('#search_songs').click()

            $('#lastfm_modal').modal 'hide'

        $('button.del_playlist').live 'click', (e) ->
          if confirm 'Are you sure you want to delete that playlist? This cannot be undone!'
            $(@).parent().hide()
            $.ajax
              type: 'DELETE'
              url: '/playlist/' + $(@).data 'id'
            .success (data) =>
              $(@).parent().remove()
              local_playlists = JSON.parse localStorage.getItem 'playlists'
              if local_playlists
                delete local_playlists[$(@).data('id')]
                localStorage.setItem 'playlists', JSON.stringify local_playlists
            .error (data) =>
              $(@).parent().show()

        $('#show_gs_playlist').live 'click', (e) ->
          if not jspf.playlist.extension[gs_playlist_rel]?
            alert 'You must save the playlist, first.'
            return
          url = jspf.playlist.extension[gs_playlist_rel][0].url
          url = url.replace 'listen.', ''
          $(grooveshark_playlist_link_modal_template
            url: url
          ).modal()

        $('button.getSong').live 'click', (e) ->
          getSong $(@).parent().parent().index(), ->
            # DO NOTHING
          return false
        
        $('#song_modal_search').live 'click', (e) ->
          getSong $(window.selectedRow).index(), null, true
          return false

        $('.uploaded_playlist button.editTrack').live 'click', (e) ->
          e.stopPropagation()

          window.selectedRow = $(@).parent().parent()[0]
          i = $(selectedRow).index()
          song = jspf.playlist.track[i]
          $('#song_modal').html song_modal_template song
          $('#song_modal .modal_search_results').html song_modal_search_results_template song
          $('#song_modal').modal()
          #getSong $(window.selectedRow).index(), null, true

        $('#song_modal input').live 'change', ->
          i = $(selectedRow).index()
          song = jspf.playlist.track[i]
          delete song.chosen
          attr_name = $(@).attr 'name'
          song[attr_name] = $(@).val()
          newRow = playlist_row_template
            track: song
            index: i
          $(window.selectedRow).replaceWith $(newRow)
          $('#playlist_items').sortable 'refresh'
          window.selectedRow = $('.uploaded_playlist tbody tr')[i]
          getSong $(window.selectedRow).index(), null, true
          update_del_song_button()
          playlistDirtied()
        
        $('#song_modal form').live 'submit', (e) ->
          e.preventDefault()
          return false

        $('#song_modal button.select-song').live 'click', (e) ->
          e.preventDefault()
          $('#song_modal button.select-song').removeClass('active').removeClass('chosen')
          $(@).addClass('active').addClass('chosen')

          i = $(selectedRow).index()
          gs_song_idx = parseInt $(@).data 'gs-song-index'
          track = jspf.playlist.track[i]
          for song in track.extension[gs_songs_rel]
            delete song['selected']
            delete song['chosen']
          track.extension[gs_songs_rel][gs_song_idx].selected = true
          track.chosen = true
          $(window.selectedRow).replaceWith playlist_row_template index:i, track:track
          $('#playlist_items').sortable 'refresh'
          window.selectedRow = $('.uploaded_playlist tbody tr')[i]
          update_del_song_button()
          playlistDirtied()

          return false
        
        $('#save_playlist').live 'click', ->
          $('#save_playlist').button 'loading'
          to_save = $.extend true, jspf, {}
          for track in to_save.playlist.track
            arr=track.extension[gs_songs_rel] or []
            if arr.length
              for ext in arr
                if ext.selected in [true, 'true']
                  track.extension[gs_songs_rel] = [ext]
          if playlist_id is null
            type = 'POST'
            url = '/new_playlist'
          else
            type = 'PUT'
            url = '/save_playlist/' + playlist_id

          gs_playlist =
            name: jspf.playlist.creator + ' - ' + jspf.playlist.title
            tracks: []
          if jspf.playlist.extension[gs_playlist_rel]?
            gs_playlist.id = jspf.playlist.extension[gs_playlist_rel][0].id
          for track in jspf.playlist.track
            ext = track.extension[gs_songs_rel]
            if ext? and ext.length? and ext.length > 0
              for song in ext
                if song.selected
                  gs_playlist.tracks.push song.SongID
                  break
          to_save.playlist.extension = to_save.playlist.extension or {}

          setTimeout ->
            xhr = $.ajax
              type: type
              cache: false
              url: url
              data:
                gs_playlist: gs_playlist
                jspf: to_save
            .success (data) =>
              playlistSaved()
              playlist_id = data.id
              jspf.playlist.extension[gs_playlist_rel] = [{
                id: data.gs_id
                url: data.gs_url
              }]

              if not logged_in
                try
                  local_playlists = JSON.parse localStorage.getItem('playlists') or {}
                catch e
                  local_playlists = {}

                local_playlists[playlist_id] =
                  id: playlist_id
                  track_count: jspf.playlist.track.length
                  title: jspf.playlist.title
                  creator: jspf.playlist.creator

                localStorage.setItem 'playlists', JSON.stringify local_playlists

              if url is '/new_playlist'
                expires = xhr.getResponseHeader 'Expires'
                if expires?
                  addExpiresMsg expires

              app.setLocation '#/playlist/' + data.id
            .error (xhr, err, thrown) =>
              playlistDirtied()
          , 200

        playlist_loaded = ->

          #=====================
          # Found here: http://stackoverflow.com/questions/1307705/jquery-ui-sortable-with-table-and-tr-width/1372954#1372954
          tableDragHelper = (e, tr) ->
            $originals = tr.children()
            $helper = tr.clone()
            $helper.children().each (index) ->
              # Set helper cell sizes to match the original sizes
              $(@).width $originals.eq(index).width()
              $(@).css
                'max-width': $originals.eq(index).width()
            $helper
          #
          #=====================
          
          row_deleted = false
          old_pos = undefined
          drag_item = undefined
          
          $('table tbody').sortable
            distance: 20
            helper: tableDragHelper
            start: (e, ui) ->
              row_deleted = false
              ui.helper.fadeTo 0, 0.5
              $('#del_song').attr 'disabled', false
              old_pos = ui.item.index()
              drag_item = ui.item
            stop: (e, ui) ->
              #$('#del_song').hide()
              $('#add_song_group').show()
              update_del_song_button()
              $('#del_song').removeClass 'warning'
            update: (e, ui) ->
              return if row_deleted
              new_pos = ui.item.index()
              diff = -(old_pos-new_pos) / Math.abs old_pos-new_pos
              i = old_pos
              ###
              while i != (new_pos + diff)
                $(arr[i]).attr
                  'data-track-index': i
                .data 'track-index': i
                i += diff
              ###
              jspf_item = jspf.playlist.track[old_pos]
              jspf.playlist.track.remove old_pos
              jspf.playlist.track.splice new_pos, 0, jspf_item

              playlistDirtied()
          .disableSelection()

          $('#del_song').droppable
            over: (e, ui) ->
              $('#del_song').addClass 'warning'
            out: (e, ui) ->
              $('#del_song').removeClass 'warning'
            drop: (e, ui) ->
              row_deleted = true
              jspf.playlist.track.remove old_pos
              drag_item.remove()
              playlistDirtied()
            tolerance: 'pointer'
          $('#del_song').click ->
            arr = $('#playlist_items tr.selected').toArray()
            for el in arr
              idx = $(el).index()
              jspf.playlist.track.remove idx
              $(el).remove()
            if arr.length > 0
              playlistDirtied()
            $(@).attr 'disabled','disabled'

        @get '#/search', ->
          $('#album_search_modal').modal()
          @redirect '#/new_playlist'

        $('#lastfm_main').click ->
          $('#lastfm_modal').modal()
          app.setLocation '#/new_playlist'

        @get '#/new_playlist', ->
          if confirmDialogShown
            return

          new_playlist =
            playlist:
              creator: 'Anonymous'
              title: 'New Playlist'
              info: 'http://spiffyshark.com'
              track: []
              extension: {}

          playlist_id = null
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/help"]').parent().addClass 'active'
          $('.content').hide()
          $('#playlist').show()
          $('#save_playlist').button('reset').attr('disabled','disabled')
          $('#playlist_items').html ''
          jspf = $.extend true, new_playlist, {}

          jspf.playlist.creator = $('#username').val() or 'Anonymous'
          $('#playlist legend').html playlist_legend_template jspf.playlist

          playlist_loaded()

          $('#save_playlist').button 'reset'
          $('#save_playlist').attr 'disabled', 'disabled'

        @get '#/', ->
          #$('.navbar .brand').hide()
          $('.nav .active').removeClass 'active'
          $('.content').hide()
          $('#main').show()
          $('#brand_row').show()

        @get '#/faq', ->
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/faq"]').parent().addClass 'active'
          $('.content').hide()
          $('#faq').show()

        @get '#/thanks', ->
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/thanks"]').parent().addClass 'active'
          $('.content').hide()
          $('#thanks').show()

        @get '#/about', ->
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/about"]').parent().addClass 'active'
          $('.content').hide()
          $('#about').show()

        @get '#/playlists', ->
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/playlists"]').parent().addClass 'active'
          $('.content').hide()
          $('#playlists').show()


          try
            local_playlists = JSON.parse localStorage.getItem 'playlists'
          catch e
            local_playlists = {}
          for own id,p of local_playlists
            p.local = true
            if $("#xspf_playlists_list > li[data-playlist-id=#{id}]").length is 0
              $('#xspf_playlists_list').prepend xspf_playlist_row_template p
          $('[rel=tooltip][data-original-title]').tooltip()

          if logged_in
            $.getJSON('/playlists')
              .success (data) ->
                $('#xspf_playlists_list > li[data-local=false]').remove()
                #$('#gs_playlists_list').html ''
                #for p in data.gs.playlists
                #  $('#gs_playlists_list').append gs_playlist_row_template p
                for p in data.xspf.playlists
                  $('#xspf_playlists_list').prepend xspf_playlist_row_template p
              .complete ->
                $('#playlists .animooted').remove()
                $('[rel=tooltip][data-original-title]').tooltip()
          
        @get '#/playlist/:id', ->
          if playlist_id is @params.id
            $('.nav .active').removeClass 'active'
            $('.content').hide()
            $('#playlist').show()
            $('#playlist_loading').hide()
            playlist_loaded()
            return
          else
            $('.nav .active').removeClass 'active'
            $('.content').hide()
            $('#playlist_items').html ''
            $('#playlist').hide()
            $('#playlist_loading').show()

          params_id = @params.id
          xhr = $.get('/playlist/'+@params.id).success (data) ->
            playlist_id = params_id

            $('#playlist_loading').hide()
            $('#playlist').show()

            setTimeout ->
              $('#playlist_top').affix
                offset: $('#playlist_top').position()
            , 10

            switch xhr.getResponseHeader 'Content-Type'
              when 'application/xspf+xml'
                if typeof data is 'string'
                  xspf_dom = XSPF.XMLfromString data
                else
                  xspf_dom = data
                jspf = XSPF.toJSPF xspf_dom
              when 'application/json'
                jspf = data

            jspf.playlist.track = jspf.playlist.track or []
            $('#playlist legend').html playlist_legend_template jspf.playlist

            i=0
            for track in jspf.playlist.track
              $('#playlist_items').append playlist_row_template
                track:track
                index:i
              ++i

            playlist_loaded()

            expires = xhr.getResponseHeader 'Expires'
            not_yours = xhr.getResponseHeader 'NotYours'

            if not_yours
              # Delete GS playlist info so when it is saved, it creates
              #  a new playlist instead of trying to overwrite the anonymous
              #  playlist.
              delete jspf.playlist.extension[gs_playlist_rel]
              playlist_id = null

            if expires
              addExpiresMsg expires

            console.log jspf

          .error (xhr, err, thrown) =>
            $('#playlist').hide()
            $('#playlist_loading').hide()
            app.setLocation '#/'

        $('#upload_btn').click (e) ->
          e.preventDefault()

          $('#upload_file').click()
          
          return false

        $('#upload input[type=file]').change ->
          $('#upload').submit()

        @post '#/upload_playlist', ->
          file = $('#upload input[type=file]')[0].files[0]
          data = new FormData
          data.append 'file', $('#upload input[type=file]')[0].files[0]
          $.ajax
            type: 'POST'
            url:'/playlist'
            data: data
            cache: false
            contentType: false
            processData: false
          .success (data) =>
            # Download the playlist we just uploaded. LOL
            @redirect '#/playlist/' + data.id

          return false

      app.run('#/')

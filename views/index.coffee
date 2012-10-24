div class:'content', id:'help', ->
  h2 'Help contents go here.'

if @user
  div class:'content', id:'playlists', ->
    div class:'span5', ->
      legend ->
        text 'Your Grooveshark Playlists'
      i class:'icon-refresh animooted'
      ul id:'gs_playlists_list', class:'playlists_list'

    div class:'span5', ->
      legend 'Your XSPF Playlists'
      i class:'icon-refresh animooted'
      ul id:'xspf_playlists_list', class:'playlists_list'

div class:'content', id:'playlist', ->
  i class:'icon-refresh animooted'
  text 'Please Wait...'

div id:'song_modal', class:'modal hide', ->
  div class:'modal-header', ->
    button type:'button', class:'close', 'data-dismiss':'modal', 'aria-hidden':'true', -> text '&times'
    h3 'Edit Song Details'

  div class:'modal-body', ->
    form class:'form-horizontal', ->
      div class:'control-group', ->
        label class:'control-label', for:'creator', 'Artist'
        div class:'controls', ->
          input class:'input-xlarge', type:'text', name:'creator'
      div class:'control-group', ->
        label class:'control-label', for:'title', 'Title'
        div class:'controls', ->
          input class:'input-xlarge', type:'text', name:'title'

coffeescript ->
  window.scripts.push ->
    playlist_dom = {}

    playlist_row = ->
      tr 'data-track-index':@index, ->
        td class:'creator', ->
          text @track.creator
        td class:'title', ->
          text @track.title
        #td class:'location', ->
        #  text track.location[0] if track.location.length > 0
        td class:'gs', ->
          button class:'btn getSong', 'Search'

    playlist_row_template = coffeecup.compile playlist_row

    playlist_template = coffeecup.compile ->
      div id:'playlist_top', 'data-spy':'affix', 'data-offset-top':'100', class:'row', ->
        button id:'search_songs', class:'btn btn-inverse btn-large', ->
          strong 'Search For Songs on Grooveshark'
        button style:'display:none', id:'generate_playlist', class:'btn btn-inverse btn-large', ->
          strong 'I\'m all done; Generate my Grooveshark Playlist!'
        br ''
        strong id:'disconnected_msg', 'Uh oh! Connection lost. Try refreshing the page.'
      legend "#{@title} by #{@creator}"
      table class:'uploaded_playlist table table-condensed table-striped', ->
        thead ->
          tr ->
            th 'Artist'
            th 'Title'
            #th 'Location'
            th ''
        tbody ''
    
    song_search_result_template = coffeecup.compile ->
      return if not @songs?
      song = @songs[0]
      if not song?
        button class:'btn getSong', 'None Found. Try Again'
        return

      a href:"/gs_song/#{song.SongID}", target:'_new', ->
        img src:"http://images.grooveshark.com/static/albums/30_#{song.CoverArtFilename or 'album'}"
        text " #{song.ArtistName} - #{song.SongName} (#{song.AlbumName})"

    gs_playlist_row_template = coffeecup.compile ->
      li 'data-playlist-id':@PlaylistID, ->
        text @PlaylistName

    xspf_playlist_row_template = coffeecup.compile ->
      li 'data-playlist-id':@url, ->
        split = @url.split '/'
        a href:'#/playlist/'+encodeURIComponent(@url), ->
          text @title
          if @creator
            text ' by ' + @creator

    error_template = coffeecup.compile ->
      for err in @errors
        div class:'alert alert-error fade in', 'data-debug-info':err.debug_info, ->
          button type:'button', class:'close', 'data-dismiss':'alert', '×'
          strong 'Error: '
          text err.msg

    alert_template = coffeecup.compile ->
      for err in @errors
        div class:'alert fade in', 'data-debug-info':err.debug_info, ->
          button type:'button', class:'close', 'data-dismiss':'alert', '×'
          strong 'Warning: '
          text err.msg
    $ ->
      window.playlist_dom = {}
      window.playlist_jspf = {}
      window.playlist = {}
      connected = false

      s = io.connect()

      s.on 'connect', ->
        $('#disconnected_msg').hide()
        $('#search_songs').show()
        connected = true

      s.on 'disconnect', ->
        $('#search_songs').hide()
        $('#disconnected_msg').show()
        connected = false

      app = new Sammy ->
        $('#content').ajaxError (e, xhr, settings, thrown) =>
          msg = thrown
          try
            resp = $.parseJSON xhr.responseText
          catch e
            resp = {}
          $('#msgs').prepend error_template errors: [
            msg: resp.err.msg or msg
          ]

        getSong = (el, cb) ->
          i = parseInt $(el).data('track-index')
          song = playlist_jspf.playlist.track[i]
          $(el).find('td.gs').html '<i class="icon-refresh animooted"></i>'
          s.emit 'song',
            creator: song.creator
            title: song.title
          , (data) ->
            if data.err
              $(el).find('td.gs').html 'ERROR <button class="btn btn-small getSong">Try Again</button>'
              cb null
              return
            if false and data.eta?
              console.log data
              $(el).find('td.gs').text "#{(data.eta / 1000)} seconds"
            else
              rel = 'http://spiffyshark.com/gs_song_id'
              $(el).find('td.gs').html song_search_result_template data
              if data.songs? and data.songs.length > 0
                playlist.tracks[i] = data.songs[0].SongID
                new_link = []
                for link in song.link
                  if not link[rel]?
                    new_link.push link
                for gs_song in data.songs
                  link = {}
                  link[rel] = gs_song.SongID
                  new_link.push link
                song.link = new_link

            cb null


        $('#search_songs').live 'click', (e) ->
          $(@).attr('disabled','disabled').html """
            <i class='icon-refresh icon-white animooted'></i>
            Please Wait...
          """
          async.forEachLimit $('.uploaded_playlist tbody tr'), 2, (el, cb) =>
            getSong el, cb
          , (err) ->
            console.log err
            $('#search_songs').hide()
            $('#generate_playlist').show()

        $('#generate_playlist').live 'click', (e) ->
          $.ajax
            url:'/grooveshark_playlist'
            data: window.playlist
            type: 'POST'
          .success (data) =>
            # Download the playlist we just uploaded. LOL
            #@redirect '#/playlist/' + encodeURIComponent data.url
            $('#generate_playlist').hide().after($("<a href=#{data.url.replace('listen.','')}>View Your Playlist!</a>"))

        $('button.getSong').live 'click', (e) ->
          getSong $(@).parent().parent(), ->
            # DO NOTHING
          return false

        $('.uploaded_playlist tbody tr').live 'click', ->
          window.selectedRow = $(@)
          i = parseInt $(@).data('track-index')
          song = playlist_jspf.playlist.track[i]
          $('#song_modal input[name=creator]').val song.creator
          $('#song_modal input[name=title]').val song.title
          $('#song_modal').modal()

        $('#song_modal input').live 'change', ->
          i = parseInt window.selectedRow.data('track-index')
          song = playlist_jspf.playlist.track[i]
          attr_name = $(@).attr 'name'
          song[attr_name] = $(@).val()
          newRow = $(playlist_row_template
            track: song
            index: window.selectedRow.data 'track-index'
          )
          window.selectedRow.replaceWith newRow
          window.selectedRow = newRow

        @get '#/', ->
          $('.nav .active').removeClass 'active'
          $('.content').hide()
          $('#main').show()

        @get '#/help', ->
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/help"]').parent().addClass 'active'
          $('.content').hide()
          $('#help').show()

        @get '#/playlists', ->
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/playlists"]').parent().addClass 'active'
          $('.content').hide()
          $('#playlists').show()

          $.getJSON('/playlists')
            .success (data) ->
              for p in data.gs.playlists
                if not $("#gs_playlists_list [data-playlist-id=#{p.PlaylistID}]").length > 0
                  $('#gs_playlists_list').append gs_playlist_row_template p
              for p in data.xspf.playlists
                if not $("#xspf_playlists_list [data-playlist-id=\"#{p.url}\"]").length > 0
                  $('#xspf_playlists_list').append xspf_playlist_row_template p
            .complete ->
              $('#playlists .animooted').remove()

        @get '#/playlist/:url', ->
          $('.nav .active').removeClass 'active'
          $('.content').hide()
          $('#playlist').show()
          xhr = $.get(@params.url).success (data) ->
            if typeof data is 'string'
              data = XSPF.XMLfromString data
            window.playlist_dom = data
            window.playlist_jspf = XSPF.toJSPF window.playlist_dom
            console.log window.playlist_jspf.playlist
            expires = xhr.getResponseHeader 'Expires'
            playlist.title = playlist_jspf.playlist.title
            playlist.tracks = []

            try
              $('#playlist').html playlist_template window.playlist_jspf.playlist
              i=0
              for track in window.playlist_jspf.playlist.track
                $('#playlist .uploaded_playlist tbody').append playlist_row_template {track:track, index:i}
                ++i

              $('#playlist_top').affix()
            catch e
              $('#playlist').html ''
              $('#msgs').prepend error_template errors: [
                msg: '''Unexpected error parsing file.
                Are you sure it is a <a href="http://xspf.org" target="_new">XSPF</a> playlist?'''
              ]

            if expires
              $('#msgs').prepend alert_template errors: [
                msg:"""Since you are not logged in, this playlist file expires <strong>#{moment(expires).fromNow()}</strong>.
                <br/>
                Log in with your Grooveshark account, and you can:
                <ul>
                  <li>Keep your playlist files here permanently.
                  <li>Export your playlist files to Grooveshark playlists.
                </ul>
                """
              ]
          .error (xhr, err, thrown) =>
            $('#playlist').html ''

        @post '#/upload_playlist', ->
          file = $('#upload input[type=file]')[0].files[0]
          data = new FormData
          data.append 'file', $('#upload input[type=file]')[0].files[0]
          $.ajax
            url:'/upload_playlist'
            data: data
            cache: false
            contentType: false
            processData: false
            type: 'POST'
          .success (data) =>
            # Download the playlist we just uploaded. LOL
            @redirect '#/playlist/' + encodeURIComponent data.url

          return false

      app.run('#/')

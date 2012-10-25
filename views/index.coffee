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

coffeescript ->
  window.scripts.push ->
    window.gs_songs_rel = 'http://spiffyshark.com/app/gs_songs'

    song_modal_template = coffeecup.compile ->
      div class:'modal-header', ->
        button type:'button', class:'close', 'data-dismiss':'modal', 'aria-hidden':'true', -> text '&times'
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

          div class:'modal_search_results'

    song_modal_search_results_template = coffeecup.compile ->
      track_info = (song, index) ->
        btn_class = 'select-song btn'
        if song.selected
          btn_class += ' active'
        button class:btn_class, 'data-toggle':'button', 'data-gs-song-index':''+index, ->
          i class:'icon-ok'
        div class:'track_info', 'data-gs-song-index':index, ->
          text ' '
          img class:'album_art', src:"http://images.grooveshark.com/static/albums/40_#{song.CoverArtFilename or 'album'}"
          div class:'track_title', ->
            a href:"/gs_song/#{song.SongID}", target:'_blank', ->
              text ' ' + song.SongName
          div class:'track_artist_album', ->
            a href:"/gs_artist/#{song.ArtistID}", target:'_blank', ->
              text song.ArtistName
            text ' • '
            a href:"/gs_album/#{song.AlbumID}", target:'_blank', ->
              text song.AlbumName

      @extension = @extension or {}
      songs = @extension[gs_songs_rel]
      if not songs?
        return
      
      if songs.length is 0
        text 'No songs found :('
        return

      ul ->
        idx = 0
        for song in songs
          li ->
            track_info song, idx
          ++idx

    playlist_template = coffeecup.compile ->
      div id:'playlist_top', 'data-spy':'affix', 'data-offset-top':'100', class:'row', ->
        button id:'search_songs', class:'btn btn-inverse btn-large', ->
          strong 'Search'
        button id:'save_playlist', class:'btn btn-inverse btn-large', ->
          strong 'Save'
        button id:'generate_playlist', class:'btn btn-inverse btn-large', ->
          strong 'Export to Grooveshark!'
        br ''
        strong id:'disconnected_msg', 'Uh oh! Connection lost. Try refreshing the page.'
      legend "#{@title} by #{@creator}"


      table class:'uploaded_playlist table table-condensed table-striped', ->
        thead ->
          tr ->
            th ''
            #th ''
            th 'Grooveshark Track'
            th 'Playlist Track'
        tbody ''

    playlist_row = ->
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

      tr class:row_class, 'data-track-index':@index, ->
        td class:'button', ->
          button class:'btn editTrack', -> i class:'icon-pencil'

        #td class:'button', ->
        #  button class:'btn getSong', -> i class:'icon-search'

        td class:'gs', ->
          div class:'track_info',  ->
            if not song?
              if songs?
                text 'None Found :('
              return
            text ' '
            img class:'album_art', src:"http://images.grooveshark.com/static/albums/40_#{song.CoverArtFilename or 'album'}"
            div class:'track_title', ->
              a href:"/gs_song/#{song.SongID}", target:'_blank', ->
                text ' ' + song.SongName
            div class:'track_artist_album', ->
              a href:"/gs_artist/#{song.ArtistID}", target:'_blank', ->
                text song.ArtistName
              text ' • '
              a href:"/gs_album/#{song.AlbumID}", target:'_blank', ->
                text song.AlbumName

        td class:'playlist', ->
          div class:'track_info', ->
            div class:'track_title', ->
              text @track.title
            div class:'track_artist_album', ->
              text @track.creator
              if @track.album
                text " • #{@track.album}"

    playlist_row_template = coffeecup.compile playlist_row

    gs_playlist_row_template = coffeecup.compile ->
      li 'data-playlist-id':@PlaylistID, ->
        text @PlaylistName

    xspf_playlist_row_template = coffeecup.compile ->
      li 'data-playlist-id':@id, ->
        a href:'#/playlist/'+@id, ->
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
      window.playlist_jspf = {}
      playlist_id = null

      connected = false

      s = io.connect()

      s.on 'connect', ->
        $('#disconnected_msg').hide()
        connected = true

      s.on 'disconnect', ->
        $('#disconnected_msg').show()
        connected = false

      app = new Sammy ->
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

          $('#msgs').prepend error_template errors: [
            msg: msg
          ]

        getSong = (el, cb, updateModal=false) ->
          i = parseInt $(el).data('track-index')
          track = playlist_jspf.playlist.track[i]
          $(el).find('button.getSong').attr('disabled','disabled').html '<i class="icon-refresh animooted"></i>'
          $(el).find('td.gs').html '<i class="icon-refresh animooted"></i>'
          if updateModal
            $('#song_modal .modal_search_results').html '<i class="icon-refresh animooted"></i>'
          s.emit 'song',
            creator: track.creator
            title: track.title
          , (data) ->
            if data.err
              $(el).find('td.gs').html 'Error!'
              cb null if cb?
              return
            track.extension[gs_songs_rel] = data.songs
            newRow = playlist_row_template index:i, track:track

            $(el).replaceWith newRow
            if updateModal
              window.selectedRow = $("tr[data-track-index=#{i}]")[0]
              $('#song_modal .modal_search_results').html song_modal_search_results_template track

            cb null if cb?

        hasSearched = (el) ->
          playlist_jspf.playlist.track[$(el).data 'track-index'].extension[gs_songs_rel]

        $('#search_songs').live 'click', (e) ->
          window.searches_break = false
          async.forEachLimit $('.uploaded_playlist tbody tr'), 2, (el, cb) =>
            if window.searches_break
              cb 'break'
              return

            if hasSearched el
              cb null
              return

            getSong el, cb
          , (err) ->

        $('#stop_search_songs').live 'click', (e) ->
          window.searches_break = true

        $('#generate_playlist').live 'click', (e) ->
          gs_playlist =
            title: playlist_jspf.playlist.title
            tracks: []
          for track in playlist_jspf.playlist.track
            ext = track.extension[gs_songs_rel]
            if ext? and ext.length? and ext.length > 0
              for song in ext
                if song.selected
                  gs_playlist.tracks.push song.SongID
                  break
          $.ajax
            url:'/grooveshark_playlist'
            data: gs_playlist
            type: 'POST'
          .success (data) =>
            # Download the playlist we just uploaded. LOL
            $('#generate_playlist').hide().after($("<a href=#{data.url.replace('listen.','')}>View Your Playlist!</a>"))

        $('button.getSong').live 'click', (e) ->
          getSong $(@).parent().parent(), ->
            # DO NOTHING
          return false

        $('.uploaded_playlist tbody button.editTrack').live 'click', ->
          window.selectedRow = $(@).parent().parent()[0]
          i = parseInt $(window.selectedRow).data('track-index')
          song = playlist_jspf.playlist.track[i]
          $('#song_modal').html song_modal_template song
          $('#song_modal .modal_search_results').html song_modal_search_results_template song
          $('#song_modal').modal()
          if not hasSearched window.selectedRow
            getSong window.selectedRow, null, true

        $('#song_modal input').live 'change', ->
          i = parseInt $(window.selectedRow).data('track-index')
          song = playlist_jspf.playlist.track[i]
          attr_name = $(@).attr 'name'
          song[attr_name] = $(@).val()
          newRow = playlist_row_template
            track: song
            index: $(window.selectedRow).data 'track-index'
          $(window.selectedRow).replaceWith $(newRow)
          window.selectedRow = $("tr[data-track-index=#{i}]")[0]
          getSong window.selectedRow, null, true
        
        $('#song_modal form').live 'submit', (e) ->
          e.preventDefault()
          return false

        $('#song_modal button.select-song').live 'click', (e) ->
          e.preventDefault()
          $('#song_modal button.select-song').removeClass 'active'
          $(@).addClass 'active'

          i = parseInt $(window.selectedRow).data('track-index')
          gs_song_idx = parseInt $(@).data 'gs-song-index'
          track = playlist_jspf.playlist.track[i]
          for song in track.extension[gs_songs_rel]
            delete song['selected']
          track.extension[gs_songs_rel][gs_song_idx].selected = true
          $(window.selectedRow).replaceWith playlist_row_template index:i, track:track
          window.selectedRow = $("tr[data-track-index=#{i}]")[0]

          return false
        
        $('#save_playlist').live 'click', ->
          $.ajax
            type: 'PUT'
            cache: false
            url:'/save_playlist/' + playlist_id
            data: playlist_jspf
          .success (data) =>
            console.log data
            alert 'Saved!'

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
                if not $("#xspf_playlists_list [data-playlist-id=\"#{p.id}\"]").length > 0
                  $('#xspf_playlists_list').append xspf_playlist_row_template p
            .complete ->
              $('#playlists .animooted').remove()

        @get '#/playlist/:id', ->
          playlist_id = @params.id
          $('.nav .active').removeClass 'active'
          $('.content').hide()
          $('#playlist').show()
          xhr = $.get('/playlist/'+@params.id).success (data) ->
            console.log data
            switch xhr.getResponseHeader 'Content-Type'
              when 'application/xspf+xml'
                if typeof data is 'string'
                  xspf_dom = XSPF.XMLfromString data
                else
                  xspf_dom = data
                window.playlist_jspf = XSPF.toJSPF xspf_dom
              when 'application/json'
                window.playlist_jspf = data
            expires = xhr.getResponseHeader 'Expires'
            console.log playlist_jspf

            $('#playlist').html playlist_template window.playlist_jspf.playlist
            i=0
            for track in window.playlist_jspf.playlist.track
              $('#playlist .uploaded_playlist tbody').append playlist_row_template {track:track, index:i}
              ++i

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

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

coffeescript ->
  playlist_dom = {}
  playlist_template = coffeecup.compile ->
    legend "#{@title} by #{@creator}"
    center ->
      button id:'search_songs', class:'btn btn-inverse btn-large', ->
        strong 'Search For Songs on Grooveshark'
      button style:'display:none', id:'generate_playlist', class:'btn btn-inverse btn-large', ->
        strong 'Generate Grooveshark Playlist!'
    table class:'uploaded_playlist table table-condensed table-striped', ->
      thead ->
        tr ->
          th 'Artist'
          th 'Title'
          #th 'Location'
          th ''
      tbody ->
        i=0
        for track in @track
          tr 'data-track-index':i, ->
            td class:'creator', ->
              text track.creator
            td class:'title', ->
              text track.title
            #td class:'location', ->
            #  text track.location[0] if track.location.length > 0
            td class:'gs', ''
          ++i

  song_search_result_template = coffeecup.compile ->
    return if not @songs?
    song = @songs[0]
    return if not song?

    a href:song.url, ->
      if song.CoverArtFilename
        img src:"http://images.grooveshark.com/static/albums/30_#{song.CoverArtFilename}"
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
    div class:'row-fluid', ->
      div class:'errors_list span6', ->
        for err in @errors
          div class:'alert alert-error fade in', 'data-debug-info':err.debug_info, ->
            button type:'button', class:'close', 'data-dismiss':'alert', '×'
            strong 'Error: '
            text err.msg

  alert_template = coffeecup.compile ->
    div class:'row-fluid', ->
      div class:'errors_list span6', ->
        for err in @errors
          div class:'alert fade in', 'data-debug-info':err.debug_info, ->
            button type:'button', class:'close', 'data-dismiss':'alert', '×'
            strong 'Warning: '
            text err.msg
  $ ->
    window.playlist_dom = {}
    window.playlist_jspf = {}
    window.playlist = {}

    app = new Sammy ->
      $('#content').ajaxError (e, xhr, settings, thrown) =>
        msg = thrown
        try
          resp = $.parseJSON xhr.responseText
        catch e
          resp = {}
        $('#content').prepend error_template errors: [
          msg: resp.err.msg or msg
        ]

      getSong = (el, cb) ->
        i = parseInt $(el).data('track-index')
        song = playlist_jspf.playlist.track[i]
        $.getJSON '/song',
          creator: song.creator
          title: song.title
        .success (data) ->
          $(el).find('td.gs').html song_search_result_template data
          if data.songs? and data.songs.length > 0
            playlist.tracks[i] = data.songs[0].SongID
          setTimeout ->
            cb null
          , 100
        .error (err) ->
          $(el).find('td.gs').html 'ERROR'
          setTimeout ->
            cb null
          , 100
          

      $('#generate_playlist').live 'click', (e) ->
        $.ajax
          url:'/grooveshark_playlist'
          data: window.playlist
          type: 'POST'
        .success (data) =>
          # Download the playlist we just uploaded. LOL
          #@redirect '#/playlist/' + encodeURIComponent data.url
          $('#generate_playlist').hide().after($("<a href=#{data.url.replace('listen.','')}>View Your Playlist!</a>"))

      $('#search_songs').live 'click', (e) ->
        $(@).attr('disabled','disabled').html """
          <i class='icon-refresh animooted'></i>
          Please Wait...
        """
        async.forEachLimit $('.uploaded_playlist tbody tr'), 1, (el, cb) =>
          getSong el, cb
        , (err) ->
          console.log err
          $('#search_songs').hide()
          $('#generate_playlist').show()
      
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
          catch e
            $('#playlist').html ''
            $('#playlist').prepend error_template errors: [
              msg: '''Unexpected error parsing file.
              Are you sure it is a <a href="http://xspf.org" target="_new">XSPF</a> playlist?'''
            ]

          if expires
            $('#playlist').prepend alert_template errors: [
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

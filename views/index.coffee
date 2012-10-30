div class:'content', id:'help', ->
  h2 'Help contents go here.'

if @user
  div class:'content', id:'playlists', ->
    ###
    div class:'span5', ->
      legend ->
        text 'Your Grooveshark Playlists'
      i class:'icon-refresh animooted'
      ul id:'gs_playlists_list', class:'playlists_list'
    ###
    div class:'span6', ->
      legend 'Your XSPF Playlists'
      i class:'icon-refresh animooted'
      ul id:'xspf_playlists_list', class:'playlists_list'


div class:'content', id:'playlist', ->
  div id:'playlist_loading', ->
    i class:'icon-refresh animooted'
    text ' Loading Playlist...'

  div id:'playlist_view', ->
    div id:'playlist_top', class:'', 'data-spy':'affix', ->
      div class:'btn-toolbar',->
        div id:'add_song_group', class:'btn-group', ->
          button id:'add_song', class:'btn btn-large', ->
            i class:'icon-plus icon-white'
            text ' Add'
          button class:'btn btn-large dropdown-toggle', 'data-toggle':'dropdown', ->
            span class:'caret'
          ul class:'dropdown-menu', ->
            li ->
              #i class:'icon-search'
              a id:'add_album', tabindex:-1, href:'#', 'Album...'

        button style:'display:none', id:'del_song', class:'btn btn-large', ->
          i class:'icon-trash icon-white'
          text 'Delete'
        button id:'search_songs', class:'btn btn-large', ->
          text 'Search'
        text '&nbsp;'
        button id:'save_playlist', class:'btn btn-large', 'data-loading-text':"<i class='icon-refresh icon-white animooted'></i> Saving", 'data-saved-text':'Saved', ->
          text 'Save'
        text '&nbsp;'
        button id:'generate_playlist', class:'btn btn-large', ->
          text 'Export to Grooveshark!'
        br ''
        strong id:'disconnected_msg', 'Uh oh! Connection lost. Try refreshing the page.'

    div class:'row', ->
      legend ''
      table class:'uploaded_playlist table table-condensed table-striped', ->
        thead ->
          tr ->
            th ''
            th 'Playlist Track (Search Terms)'
            th 'Grooveshark Track (Search Results)'
        tbody ''


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
      div class:'modal hide fade', ->
        div class:'modal-body', ->
          h4 'Success!'
          p 'Click the link below to view your shiny new playlist!'
          div class:'well well-small', ->
            a class:'grooveshark_playlist_link', href:@url, ->
              text @url

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
            track_info song, idx
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
        ol class:'discogs_tracklist', ->
          for track in @tracklist
            li ->
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
              a href:"/gs_song/#{song.SongID}", target:'_blank', ->
                text ' ' + song.SongName
            div class:'track_artist_album', ->
              a href:"/gs_artist/#{song.ArtistID}", target:'_blank', ->
                text song.ArtistName
              text ' • '
              a href:"/gs_album/#{song.AlbumID}", target:'_blank', ->
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

    playlist_legend_template = coffeecup.compile ->
      span id:'playlist_title', contenteditable:'true', spellcheck:'false', @title
      text ' by '
      span id:'playlist_creator', contenteditable:'true', spellcheck:'false', @creator
    $ ->
      animooted = '<i class="icon-refresh animooted"></i>'

      $.fn.button.defaults.loadingText = ->
        animooted + ' loading...'
      
      playlistDirtied = =>
        change = window.lastChange = new Date
        window.playlistDirty = true
        $('#save_playlist').button 'reset'
        setTimeout ->
          return if not window.playlistDirty
          if lastChange - change is 0
            $('#save_playlist').click()
        , 5000

      playlistSaved = =>
        window.playlistDirty = false
        $('#save_playlist').button 'saved'
        setTimeout ->
          $('#save_playlist').attr 'disabled', 'disabled'
        , 10
      

      window.jspf = {}
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
            selected = undefined

            for song in ext
              if song.selected
                selected = song
                break
            
            if selected?
              ext = track.extension[gs_songs_rel] = [selected]
            else
              ext = track.extension[gs_songs_rel] = []

            for song in data.songs
              if selected?
                if (''+song.SongID is ''+selected.SongID)
                  selected.score = song.score
                  continue
                song.selected = false
              ext.push song

            if not selected?
              playlistDirtied()

            newRow = playlist_row_template index:i, track:track

            el.replaceWith newRow
            if updateModal
              window.selectedRow = $('.uploaded_playlist tbody tr')[i]
              $('#song_modal .modal_search_results').html song_modal_search_results_template track

            cb null if cb?

        hasSearched = (idx) ->
          return false
          jspf.playlist.track[idx].extension[gs_songs_rel]

        window.playlistDirty = false
        window.lastChange = new Date

        window.onbeforeunload = (e) ->
          if window.playlistDirty
            return e.returnValue = 'Your playlist has unsaved changes!'
          return null
        
        @before {}, ->
          if window.playlistDirty
            if not confirm 'Your playlist has unsaved changes! Are you sure you want to leave?'
              return false
            else
              window.playlistDirty = false
          return

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

        $('#search_songs').live 'click', (e) ->
          window.searches_break = false
          async.forEachLimit $('.uploaded_playlist tbody tr'), 2, (el, cb) =>

            if window.searches_break
              cb 'break'
              return

            if hasSearched $(el).index()
              cb null
              return

            i = $(el).index()
            getSong i, cb
          , (err) ->

        $('#add_song').live 'click', (e) ->
          track =
            creator: ''
            title: ''
            album: ''
            extension: {}
          idx = (jspf.playlist.track.push track) - 1
          $('#playlist .uploaded_playlist').append playlist_row_template
            track: track
            index: idx
            
          $('#playlist .uploaded_playlist tr').last().find('button.editTrack').click()

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
          $(@).button 'loading'
          $.getJSON $(@).parent().data('url') + '?callback=?'
          , (res, status, xhr) =>
            $(@).button 'reset'
            console.log res
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
              console.log track
              idx = (jspf.playlist.track.push track) - 1
              $('#playlist .uploaded_playlist').append playlist_row_template
                track: track
                index: idx
              getSong idx, null
            $('#album_search_modal').modal 'hide'
          return false

        $('#stop_search_songs').live 'click', (e) ->
          window.searches_break = true

        $('#generate_playlist').live 'click', (e) ->
          $('#generate_playlist').button 'loading'
          gs_playlist =
            title: jspf.playlist.title
            tracks: []
          for track in jspf.playlist.track
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
            $('#generate_playlist').button 'reset'
            $(grooveshark_playlist_link_modal_template
              url: data.url.replace('listen.', '')
            ).modal()

        $('button.getSong').live 'click', (e) ->
          getSong $(@).parent().parent().index(), ->
            # DO NOTHING
          return false
        
        $('#song_modal_search').live 'click', (e) ->
          if not hasSearched $(window.selectedRow).index()
            getSong $(window.selectedRow).index(), null, true

        $('.uploaded_playlist button.editTrack').live 'click', ->
          window.selectedRow = $(@).parent().parent()[0]
          i = $(selectedRow).index()
          song = jspf.playlist.track[i]
          $('#song_modal').html song_modal_template song
          $('#song_modal .modal_search_results').html song_modal_search_results_template song
          $('#song_modal').modal()
          if not hasSearched $(window.selectedRow).index()
            getSong $(window.selectedRow).index(), null, true

        $('#song_modal input').live 'change', ->
          i = $(selectedRow).index()
          song = jspf.playlist.track[i]
          attr_name = $(@).attr 'name'
          song[attr_name] = $(@).val()
          newRow = playlist_row_template
            track: song
            index: i
          $(window.selectedRow).replaceWith $(newRow)
          window.selectedRow = $('.uploaded_playlist tbody tr')[i]
          getSong $(window.selectedRow).index(), null, true
          playlistDirtied()
        
        $('#song_modal form').live 'submit', (e) ->
          e.preventDefault()
          return false

        $('#song_modal button.select-song').live 'click', (e) ->
          e.preventDefault()
          $('#song_modal button.select-song').removeClass 'active'
          $(@).addClass 'active'

          i = $(selectedRow).index()
          gs_song_idx = parseInt $(@).data 'gs-song-index'
          track = jspf.playlist.track[i]
          for song in track.extension[gs_songs_rel]
            delete song['selected']
          track.extension[gs_songs_rel][gs_song_idx].selected = true
          $(window.selectedRow).replaceWith playlist_row_template index:i, track:track
          window.selectedRow = $('.uploaded_playlist tbody tr')[i]
          playlistDirtied()

          return false
        
        $('#save_playlist').live 'click', ->
          $('#save_playlist').button 'loading'
          for track in jspf.playlist.track
            arr=track.extension[gs_songs_rel] or []
            if arr.length
              for ext in arr
                if ext.selected in [true, 'true']
                  track.extension[gs_songs_rel] = [ext]
          setTimeout ->
            $.ajax
              type: 'PUT'
              cache: false
              url:'/save_playlist/' + playlist_id
              data: jspf
            .complete =>
              playlistSaved()
            .error =>
              playlistDirtied()
          , 200

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
          $('#playlist .uploaded_playlist').html ''
          $('#playlist_view').hide()
          $('#playlist_loading').show()
          $('#playlist').show()

          xhr = $.get('/playlist/'+@params.id).success (data) ->
            $('#playlist_loading').hide()

            switch xhr.getResponseHeader 'Content-Type'
              when 'application/xspf+xml'
                if typeof data is 'string'
                  xspf_dom = XSPF.XMLfromString data
                else
                  xspf_dom = data
                window.jspf = XSPF.toJSPF xspf_dom
              when 'application/json'
                window.jspf = data
            expires = xhr.getResponseHeader 'Expires'

            console.log jspf

            $('#playlist legend').html playlist_legend_template jspf.playlist

            # Initial state is not dirty.
            playlistSaved()

            i=0
            for track in window.jspf.playlist.track
              $('#playlist .uploaded_playlist').append playlist_row_template
                track:track
                index:i
              ++i

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
              helper: tableDragHelper
              start: (e, ui) ->
                row_deleted = false
                ui.helper.fadeTo 0, 0.5
                $('#add_song_group').hide()
                $('#del_song')
                  .removeClass('btn-danger')
                  .addClass('btn-warning')
                  .show().fadeTo 0, 1
                old_pos = ui.item.index()
                drag_item = ui.item
              stop: (e, ui) ->
                $('#del_song').hide()
                $('#add_song_group').show()
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
                $('#del_song')
                  .removeClass('btn-warning')
                  .addClass('btn-danger')
                  .show().fadeTo 0, 1
              out: (e, ui) ->
                $('#del_song')
                  .removeClass('btn-danger')
                  .addClass('btn-warning')
                  .show().fadeTo 0, 1
              drop: (e, ui) ->
                row_deleted = true
                jspf.playlist.track.remove old_pos
                drag_item.remove()
                playlistDirtied()
              tolerance: 'pointer'

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

            $('#playlist_view').show()

          .error (xhr, err, thrown) =>
            $('#playlist_view').hide()
            $('#playlist_loading').hide()

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

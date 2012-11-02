

div class:'content container', id:'main', ->
  div id:'new_playlist_options', ->
    a id:'create', class:'row', href:'#/new_playlist', ->
      legend 'Create'
    hr ''
    a id:'search', class:'row', href:'#/search', ->
      legend 'Search'
    hr ''
    div id:'import', class:'row', ->
      legend 'Import'

div class:'content container', id:'help', ->
  h2 'Help contents go here.'

if @user
  div class:'content container', id:'playlists', ->
    ###
    div class:'span5', ->
      legend ->
        text 'Your Grooveshark Playlists'
      i class:'icon-refresh animooted'
      ul id:'gs_playlists_list', class:'playlists_list'
    ###
    legend 'Your Playlists'
    i class:'icon-refresh icon-white animooted'
    ul id:'xspf_playlists_list', class:'playlists_list'


div id:'playlist_loading', class:'content container', ->
  i class:'icon-refresh icon-white animooted'
  text ' Loading Playlist...'

div class:'content container', id:'playlist', ->
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
        button id:'generate_playlist', class:'btn btn-inverse btn-large', ->
          text 'Export to Grooveshark!'
        br ''
        strong id:'disconnected_msg', 'Uh oh! Connection lost. Try refreshing the page.'

  div class:'row', ->
    table class:'uploaded_playlist table table-condensed table-striped', ->
      thead ->
        tr ->
          th ''
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
            a class:'grooveshark_playlist_link', href:@url, target:'_blank', ->
              text @url

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
      addMsg = (msg) ->
        if not msg.transient
          messages = JSON.parse(localStorage.getItem('messages')) or []
          messages.push msg
          localStorage.setItem 'messages', JSON.stringify messages
        renderMsg msg

      renderMsg = (msg) ->
        switch msg.type
          when 'error'
            el = $(error_template(msg: msg))
          when 'alert'
            el = $(alert_template(msg: msg))

        $('#msgs').prepend el
        console.log el
        el.find('button.close').click ->
          messages = JSON.parse(localStorage.getItem('messages')) or []
          messages.remove $(@).parent().index()
          localStorage.setItem 'messages', JSON.stringify messages
        
      messages = JSON.parse(localStorage.getItem('messages')) or []
      for msg in messages
        renderMsg msg

      $('#show_login_form').click ->
        $(@).hide()
        $('#log-in').show()
        $('#log-in input').first().focus()

      $.fn.transitionContent = (ms) ->
        ms = ms or 250
        wrapper = $("<div>")
        trans = "width " + ms + "ms ease-out"
        el = this
        wrapper.css
          "-webkit-transition": trans
          "-moz-transition": trans
          "-o-transition": trans
          transition: trans
          width: el.css("width")
          height: el.css("height")
          margin: el.css('margin')
          padding: el.css('padding')
          background: "#f0f" # For debug
        el.css 'margin', '0'
        el.css 'padding', '0'

        el.wrap wrapper
        wrapper = el.parent()
        el.css
          width: "100%"
          height: "100%"

        el.each ->
          @addEventListener "DOMSubtreeModified", (e) ->
            clone = undefined
            w = undefined
            h = undefined
            clone = el.clone().css(
              width: ""
              height: ""
            ).hide().appendTo("body")
            w = clone.css("width")
            h = clone.css("height")
            clone.remove()
            wrapper.css
              width: w
              height: h
        el
      #$('button').transitionContent(5000)

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
        , 20

      jspf = {}
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
          $('.navbar .brand').show()

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
          $('#playlist .uploaded_playlist').append playlist_row_template
            track: track
            index: idx
            
          $('#playlist .uploaded_playlist tr').last().find('button.editTrack').click()
          $('#playlist_items').sortable 'refresh'
          playlistDirtied()

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
              track.idx = idx
              $('#playlist_items').sortable 'refresh'

            async.forEachLimit res.data.tracklist, 2, (track, cb) =>
              getSong track.idx, cb
            $('#album_search_modal').modal 'hide'
          return false

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
            url = data.url.replace('listen.', '')
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

        $('.uploaded_playlist button.editTrack').live 'click', ->
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
          console.log track.extension[gs_songs_rel]
          track.extension[gs_songs_rel][gs_song_idx].selected = true
          track.chosen = true
          $(window.selectedRow).replaceWith playlist_row_template index:i, track:track
          $('#playlist_items').sortable 'refresh'
          window.selectedRow = $('.uploaded_playlist tbody tr')[i]
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

          setTimeout ->
            $.ajax
              type: type
              cache: false
              url: url
              data: to_save
            .success (data) =>
              playlistSaved()
              playlist_id = data.id
              app.setLocation '#/playlist/' + data.id
            .error (xhr, err, thrown) =>
              playlistDirtied()
          , 200

        playlist_loaded = ->
          console.log jspf

          $('#playlist legend').html playlist_legend_template jspf.playlist

          # Initial state is not dirty.
          #playlistSaved()

          i=0
          for track in jspf.playlist.track
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
              $('#del_song').attr 'disabled', false
              old_pos = ui.item.index()
              drag_item = ui.item
            stop: (e, ui) ->
              #$('#del_song').hide()
              $('#add_song_group').show()
              $('#del_song').attr 'disabled', 'disabled'
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

        new_playlist =
          playlist:
            creator: 'Anonymous'
            title: 'New Playlist'
            info: 'http://spiffyshark.com'
            track: []

        @get '#/search', ->
          $('#album_search_modal').modal()
          @redirect '#/new_playlist'

        @get '#/new_playlist', ->
          playlist_id = null
          $('.nav .active').removeClass 'active'
          $('.nav [href="#/help"]').parent().addClass 'active'
          $('.content').hide()
          $('#playlist').show()
          $('#save_playlist').button('reset').attr('disabled','disabled')
          $('#playlist .uploaded_playlist').html ''
          jspf = $.extend new_playlist, {}
          jspf.playlist.creator = $('#username').val() or 'Anonymous'

          playlist_loaded()

          $('#save_playlist').button 'reset'
          $('#save_playlist').attr 'disabled', 'disabled'

        @get '#/', ->
          $('.navbar .brand').hide()
          $('.nav .active').removeClass 'active'
          $('.content').hide()
          $('#main').show()
          $('#brand_row').show()

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
              $('#xspf_playlists_list').html ''
              for p in data.gs.playlists
                $('#gs_playlists_list').append gs_playlist_row_template p
              $('#xspf_playlists_list').html ''
              for p in data.xspf.playlists
                $('#xspf_playlists_list').append xspf_playlist_row_template p
            .complete ->
              $('#playlists .animooted').remove()


        @get '#/playlist/:id', ->
          if playlist_id is @params.id
            $('.nav .active').removeClass 'active'
            $('.content').hide()
            $('#playlist').show()
            $('#playlist_loading').hide()
            return
          else
            $('.nav .active').removeClass 'active'
            $('.content').hide()
            $('#playlist .uploaded_playlist').html ''
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
            expires = xhr.getResponseHeader 'Expires'

            if expires
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

            playlist_loaded()

          .error (xhr, err, thrown) =>
            $('#playlist').hide()
            $('#playlist_loading').hide()
            app.setLocation '#/'

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

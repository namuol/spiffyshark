div class:'content', id:'help', ->
  h2 'Help contents go here.'

if @user
  div class:'content', id:'playlists', ->
    legend ->
      text 'Your Grooveshark Playlists'
    i class:'icon-refresh animooted'
    ul id:'playlists_list'

coffeescript ->
  playlist_template = coffeecup.compile ->
    li 'data-playlist-id':@PlaylistID, ->
      text @PlaylistName

  error_template = coffeecup.compile ->
    div class:'row-fluid', ->
      div class:'errors_list span6', ->
        for err in @errors
          div class:'alert alert-error fade in', 'data-debug-info':err.debug_info, ->
            button type:'button', class:'close', 'data-dismiss':'alert', '×'
            strong 'error: '
            text err.msg

  $ ->
    app = new Sammy ->
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
            for p in data.playlists
              if not $("#playlists_list [data-playlist-id=#{p.PlaylistID}]").length > 0
                $('#playlists_list').append playlist_template p
          .error (err) ->
            $('body').append error_template errors:err
          .complete ->
            $('#playlists .animooted').remove()

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
        .success ->
          alert 'success!'
        .error (err) ->
          $('body').append error_template errors:err

        return false

    app.run('#/')

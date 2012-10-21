if @user
  div id:'playlists', ->
    legend ->
      text 'Your Playlists'
      i class:'icon-refresh animooted'

  coffeescript ->
    $ ->
      $.getJSON('/playlists')
        .success (data) ->
          console.log data
        .error (err) ->
          console.log err
        .complete ->
          # Done.

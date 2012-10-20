config = require './config'

fs = require 'fs'
stylus = require 'stylus'

handle_errors = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr

task 'build', 'Create compiled HTML/CSS output', ->
  console.log 'build her a cake or something...'
  console.log 'building css'

  stylus.render fs.readFileSync('css/style.styl','utf-8'),
    filename: 'public/style.css'
    paths: [require('nib').path]
  , (err, css) ->
    throw err if err
    fs.writeFileSync 'public/style.css', css

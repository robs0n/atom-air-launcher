exec = require('child_process').exec
path = require 'path'
platform = require('os').platform
{SelectListView} = require 'atom-space-pen-views'

module.exports =
class AirLauncherView extends SelectListView
  initialize: ->
    super
    @lastItem = null
    @

  viewForItem: (item) ->
    '<li class="icon-file-binary">' + item.name + '</li>'

  confirmed: (item) ->
    @startApp item
    @

  getFilterKey: () ->
    'name'

  cancelled: ->
    @hide()

  hide: ->
    @modalPanel.hide()

  showItems: (items) ->
    @setItems items.filter (itm) ->
      !!itm
    @modalPanel ?= atom.workspace.addModalPanel(item: this)
    @modalPanel.show()
    @focusFilterEditor()

  startApp: (item) ->
    sdkPath = atom.config.get('air-launcher.sdkPath')
    if sdkPath
      @lastItem = item
      @cancel()
      adlPath = path.join sdkPath, 'bin', 'adl' + (if platform() == 'win32' then '.exe' else '')
      cmd = [adlPath, item.descriptor].join ' '
      exec cmd
    else
      @setError 'SDK-Path not set'

  startLast: ->
      @startApp @lastItem if @lastItem

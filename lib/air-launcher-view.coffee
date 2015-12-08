{SelectListView} = require 'atom-space-pen-views'

module.exports =
class AirLauncherView extends SelectListView
  initialize:  ->
    super
    @

  viewForItem: (item) ->
    '<li class="icon-file-binary">' + item.name + '</li>'

  confirmed: (item) ->
    console.log 'confirmed', item
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

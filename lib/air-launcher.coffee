AirLauncherView = require './air-launcher-view'
{CompositeDisposable} = require 'atom'
path = require 'path'
fs = require 'fs'
xmldom = require 'xmldom'
  .DOMParser
xpath = require 'xpath'


searchPath = (dirpath) ->
  appdescr = path.join dirpath, 'application.xml'
  new Promise (resolve, reject) ->
    fs.access appdescr, fs.R_OK, (err) ->
      if err
        resolve null
      else
        fs.readFile appdescr, 'utf8', (err, data) ->
          if err
            reject err
          else
            doc = new xmldom().parseFromString data
            name = xpath.select("/node()[local-name() = 'application']/node()[local-name() = 'name']/text()", doc).toString()
            console.log 'NAME', name
            resolve name:name, descriptor:appdescr

module.exports = AirLauncher =
  airLauncherView: null
  modalPanel: null
  subscriptions: null
  apps: null
  lastApp: null
  searchPromise: null

  activate: (state) ->
    @airLauncherView = new AirLauncherView(state.airLauncherViewState)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'air-launcher:run': => @run()
    @subscriptions.add atom.commands.add 'atom-workspace', 'air-launcher:run-last': => @runLast()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @airLauncherView.destroy()

  serialize: ->
    airLauncherViewState: @airLauncherView.serialize()

  searchProjectPaths: ->
    self = @
    @searchPromise = @searchPromise || Promise.all atom.project.getPaths().map (path) ->
      searchPath path
    .then (apps) ->
      self.searchPromise = null
      Promise.resolve apps
    .catch () ->
      self.searchPromise = null

  run: ->
    self = @
    @searchProjectPaths()
      .then (apps) ->
        self.airLauncherView.showItems apps
      .catch (err) ->
        console.error 'REJECTED', err

  runLast: ->
    console.log 'Run LASTTTSTSTS'

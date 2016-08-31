#----------------------------------------------------------------------------
#Chiika
#Copyright (C) 2016 arkenthera
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#Date: 23.1.2016
#authors: arkenthera
#Description:
#----------------------------------------------------------------------------

React                               = require('react')
{Link}                              = require('react-router')
{dialog}                            = require('electron').remote
_forEach                            = require 'lodash.foreach'


CheckboxOption = React.createClass
  getInitialState: ->
    label: ''
    id:''
    checked: false
  componentWillReceiveProps: (props) ->
    @setState { label: props.label, checked: chiika.getOption(props.id),id : props.id }

  componentDidMount: ->
    @setState { label: @props.label, checked: chiika.getOption(@props.id),id : @props.id }

  onChange: (e) ->
    @setState { checked: $(e.target).prop('checked')}

    chiika.setOption(@state.id,$(e.target).prop('checked'))
  render: ->
    <div>
      <label className="checkbox danger">
        <input type="checkbox" id="#{@state.label}" onChange={@onChange} checked={@state.checked} />
        { @state.label }
      </label>
    </div>

DropdownOption = React.createClass
  getInitialState: ->
    options: []
    label: ''
    defaultValue: ''
  componentWillReceiveProps: (props) ->
    @setState { label: props.label, options: props.options,id: props.id, defaultValue: props.defaultValue }

  componentDidMount: ->
    @setState { label: @props.label, options: @props.options,id: @props.id, defaultValue: @props.defaultValue }

  componentDidUpdate: ->
    $("##{@state.id}_select option[value=#{@state.defaultValue}]").attr('selected','selected')

  onChange: (e) ->
    value = $(e.target).val()
    @props.onChange(value)
  render: ->
    <div>
      <span>
        { @state.label }
        <select id="#{@state.id}_select" className="button lightblue" name="" onChange={@onChange}>
          { @state.options.map (option,i) =>
            <option value={option} key={i}>{option}</option>
          }
        </select>
      </span>
    </div>

AppSettings = React.createClass
  render: ->
    <div className="card">
      <CheckboxOption label="Disable Anime Recognition" id="DisableAnimeRecognition" />
      <CheckboxOption label="Remember Window Position & Size" id="RememberWindowSizeAndPosition" />
      <CheckboxOption label="Close to tray" id="CloseToTray" />
      <CheckboxOption label="Minimize to tray" id="MinimizeToTray" />
      <CheckboxOption label="Launch minimized on startup" id="LaunchMinimized" />
      <CheckboxOption label="Check for Updates" id="CheckForUpdates" />
      <CheckboxOption label="Disable transparency (Transparency might not work on some OSes)" id="NoTransparentWindows" />
    </div>

Recognition = React.createClass
  getInitialState: ->
    libraryPaths: chiika.getOption('LibraryPaths')
  openDialog: ->
    folders = dialog.showOpenDialog({
      properties: ['openDirectory','multiSelections']
    })

    if folders?
      folderText = ""
      _forEach folders, (folder) =>
        folderText += folder + "\n"
      @setState { libraryPaths: folderText }
      chiika.setOption('LibraryPaths',folders)
  scanLibrary: ->
    chiika.toastLoading('Scanning library...','infinite')
    chiika.scanLibrary()

  render: ->
    <div className="card">
      <textarea name="description" disabled value={@state.libraryPaths} onChange={@onChange} />
      <button type="button" className="button raised primary" onClick={@openDialog}>Browse..</button>
      <button type="button" className="button raised primary" onClick={@scanLibrary}>Scan library</button>
    </div>

ListGeneral = React.createClass
  componentDidMount: () ->

  render: ->
    <div>
      <div className="card">
        <div className="title">
          <h4>Grid</h4>
        </div>
      </div>
      <div className="card">
        <div className="title">
          <h4>Tabs</h4>
        </div>
        <div>
          <CheckboxOption label="Extra grid features" id="RememberSortingPreference" />
        </div>
      </div>
    </div>

RSSSettings = React.createClass
  onRSSSourceChanged: (newSource) ->
    chiika.setOption('DefaultRssSource',newSource)
    chiika.ipc.refreshViewByName('cards_news','cards')
  render: ->
    <div className="card">
      <DropdownOption label="Default RSS Source" options={chiika.appSettings.RSSSources} id="DefaultRssSource" defaultValue="#{chiika.getOption('DefaultRssSource')}" onChange={@onRSSSourceChanged} />
    </div>

AccountSettings = React.createClass
  syncMyanimelist: ->
    chiika.toastLoading('Syncing Myanimelist...','infinite')

    chiika.ipc.refreshViewByName 'myanimelist_animelist','myanimelist',null, =>

    chiika.ipc.refreshViewByName 'myanimelist_mangalist','myanimelist',null, (params) =>
      chiika.toastSuccess('Synced myanimelist!',3000)
  render: ->
    <div className="card">
      <button type="button" className="button raised primary" onClick={@syncMyanimelist}>Sync Myanimelist</button>
    </div>


module.exports = React.createClass
  getInitialState: ->
    currentRoute: 'App'
  componentWillReceiveProps: (props) ->
    @setState { currentRoute: props.props.location.query.location }
  componentDidMount: ->
    @setState { currentRoute: @props.props.location.query.location }
  isMenuItemActive: (path) ->
    if path == @state.currentRoute
      'active'
    else
      ''
  render: ->
    <div className="settingsModal">
      <div className="navigation">
        <h5>Settings</h5>
        <ul>
          <p className="list-title">General</p>
          <Link className="side-menu-link #{@isMenuItemActive('App')}" to="#{@props.props.location.pathname}" query={{ settings:true, location: 'App' }}>
            <li>Application</li>
          </Link>
          <Link className="side-menu-link #{@isMenuItemActive('Recognition')}" to="#{@props.props.location.pathname}" query={{ settings:true, location: 'Recognition' }}>
            <li>Recognition</li>
          </Link>
          <Link className="side-menu-link #{@isMenuItemActive('Account')}" to="#{@props.props.location.pathname}" query={{ settings:true, location: 'Account' }}>
            <li>Account</li>
          </Link>
          <p className="list-title">Lists</p>
          <Link className="side-menu-link #{@isMenuItemActive('ListGeneral')}" to="#{@props.props.location.pathname}" query={{ settings:true, location: 'ListGeneral' }}>
            <li>General</li>
          </Link>
          <p className="list-title">Connections</p>
          <Link className="side-menu-link #{@isMenuItemActive('RSSSettings')}" to="#{@props.props.location.pathname}" query={{ settings:true, location: 'RSSSettings' }}>
            <li>RSS</li>
          </Link>
        </ul>
      </div>
      <div className="settings-page">
        <h2>{ @state.currentRoute }</h2>
        {
          if @state.currentRoute == 'App'
            <AppSettings />
          else if @state.currentRoute == 'ListGeneral'
            <ListGeneral {...@props} />
          else if @state.currentRoute == 'RSSSettings'
            <RSSSettings {...@props} />
          else if @state.currentRoute == 'Account'
            <AccountSettings {...@props} />
          else if @state.currentRoute == 'Recognition'
            <Recognition {...@props} />
        }
      </div>
    </div>

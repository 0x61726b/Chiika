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

React               = require('react')
{Link}              = require('react-router')


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
      <label className="checkbox">
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
      <CheckboxOption label="Remember Window Position & Size" id="RememberWindowSizeAndPosition" />
      <CheckboxOption label="Launch on startup" id="LaunchOnStartup" />
      <CheckboxOption label="Minimize when clicked close" id="MinimizeWhenClickedClose" />
      <CheckboxOption label="Launch minimized on startup" id="LaunchMinimized" />
      <CheckboxOption label="Check for Updates" id="CheckForUpdates" />
      <CheckboxOption label="Disable Bubble Notifications" id="DisableBubbleNotifications" />
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
        }
      </div>
    </div>

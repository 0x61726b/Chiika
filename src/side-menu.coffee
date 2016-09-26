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

React = require('react')
{Router,Route,BrowserHistory,Link} = require('react-router')
{BrowserWindow, ipcRenderer,remote} = require 'electron'


_find                   = require 'lodash/collection/find'
_indexOf                = require 'lodash/array/indexOf'
_forEach                = require 'lodash/collection/forEach'
_filter                 = require 'lodash/collection/filter'

path                    = require 'path'

#Views

SideMenu = React.createClass
  menuItemsSet: false
  isPendingUiItems: false
  requiresRefresh: true

  getInitialState: ->
    uiItems: []
    categories: []
  componentWillMount: ->
    chiika.ipc.refreshUIData (args) =>
      @refreshSideMenu(args)



  componentDidMount: ->
    @refreshSideMenu(chiika.uiData)

    if requiresRefresh
      @refreshSideMenu(chiika.uiData)
      requiresRefresh = false

  componentDidUpdate: ->
    # $(".side-menu-link").click ->
    #   if !this.classList.contains "active"
    #     $(".side-menu-link").removeClass "active"
    #     $(this).toggleClass "active"



  refreshSideMenu: (menuItems) ->
    if @requiresRefresh
      chiika.logger.renderer("SideMenu requires refresh!")

      @state.uiItems       = []
      @state.categories    = []

      chiika.logger.renderer("SideMenu::refreshSideMenu")

      @pendingUiItems = []
      @pendingCategories = []

      menuItemsWithViews = []
      _forEach menuItems, (menu) =>
        if menu.type == 'side-menu-item'
          findInViews = _find chiika.viewData, (o) -> o.name == menu.name

          if findInViews? && findInViews.dataSource.length > 0
            menuItemsWithViews.push menu

      _forEach menuItemsWithViews, (v,k) =>
        #Add category

        if v? && v.type == 'side-menu-item'
          if _indexOf(@pendingCategories, _find(@pendingCategories, (o) -> return o == v.category )) == -1
            @pendingCategories.push v.category

          if _indexOf(@pendingUiItems, _find(@pendingUiItems, (o) -> return v.name == o.name )) == -1
            @pendingUiItems.push v

      if @isMounted()
        @setState { uiItems: @pendingUiItems, categories: @pendingCategories }
        requiresRefresh = false

  renderCategory: (name,i) ->
    <p className="list-title" key={i}>{name}</p>

  isMenuItemActive: (path) ->
    currentPath = @props.props.location.pathname

    if "/" + path == currentPath
      'active'
    else if currentPath.indexOf(path) != -1
      'active'
  renderMenuItem: (item,i) ->
    <Link className="side-menu-link #{@isMenuItemActive(item.name)}" to="#{item.name}" key={i}>
      <li className="side-menu-li" key={i}>
        <i className="fa fa-list"></i>
        {item.display}
      </li>
    </Link>

  renderMenuItems: (category) ->
    menuItemsOfThisCategory = _filter(@state.uiItems, (o) ->
      return o.category == category)
    if menuItemsOfThisCategory.length > 0
      menuItemsOfThisCategory.map (menuItem,j) =>
        @renderMenuItem(menuItem,j + 1)

  userAvatarContextMenu: ->
    console.log "test"

    menuItems = []
    menuItems.push ( { type: 'separator'})
    _forEach chiika.users, (user) =>
      isDefault = user.isDefault

      menuItems.push ( { type: 'checkbox', label: "#{user.realUserName} - #{user.owner}", checked: isDefault})

    chiika.popupContextMenu(menuItems)

  getCoverImage: ->
    defaultUser = _find chiika.users, (o) -> o.isDefault == true
    if defaultUser?
      defaultUser.profileImage
    else
      "../assets/images/avatar.jpg"

  getDefaultUser: ->
    defaultUser = _find chiika.users, (o) -> o.isDefault == true
    if defaultUser?
      defaultUser.realUserName
    else
      "Chiika"

  render: () ->
    (<div className="sidebar">
      <div className="topLeft">
        <div className="logoContainer">
          <img className="chiikaLogo" src="../assets/images/topLeftLogo.png"/>
        </div>
        <Link to="User" className="userArea noDecoration">
          <div className="imageContainer" title="Right click to swap primary user" onContextMenu={@userAvatarContextMenu}>
            <img id="userAvatar" className="img-circle avatar" src="#{@getCoverImage()}"/>
          </div>
          <div className="userInfo">
            {@getDefaultUser()}
          </div>
        </Link>
      </div>
      <div className="navigation">
        <ul>
          <Link className="side-menu-link #{@isMenuItemActive('Home')}" to="Home"><li className="side-menu-li"><i className="fa fa-home"></i>Home</li></Link>
          {
            @state.categories.map (category,i) =>
              <div key={i}>
              {
                @renderCategory(category,i)
              }
              {
                @renderMenuItems(category)
              }
              </div>
          }
          <p className="list-title">Something</p>
          <Link className="side-menu-link #{@isMenuItemActive('Search')}" to="Search/:"><li className="side-menu-li"><i className="fa fa-search"></i>Search</li></Link>
          <Link className="side-menu-link #{@isMenuItemActive('Calendar')}" to="Calendar"><li className="side-menu-li"><i className="fa fa-calendar"></i>Calendar</li></Link>
          <Link className="side-menu-link #{@isMenuItemActive('Library')}" to="Library"><li className="side-menu-li"><i className="fa fa-archive"></i>Library</li></Link>
          <Link className="side-menu-link #{@isMenuItemActive('Torrents')}" to="Torrents"><li className="side-menu-li"><i className="fa fa-cloud-download"></i>Torrents</li></Link>
        </ul>
      </div>
    </div>)

module.exports = SideMenu

React = require 'react'
SideNav = require 'react-sidenav'

class SideNavComponent extends React.Component
  state: {
    nav: [
        {key: 'landing', title: 'Home', 'iconClassName': 'fa fa-dashboard'},
        {key: 'channels', title: 'Anime List', 'iconClassName': 'fa fa-exchange'},
        {key: 'fleet', title: 'Manga List', 'iconClassName': 'fa fa-truck'},
        {key: 'products', title: 'Library', 'iconClassName': 'fa fa-cubes'},
        {key: 'inventory', title: 'Calendar', 'iconClassName': 'fa fa-database'},
        {key: 'inventory', title: 'Torrents', 'iconClassName': 'fa fa-database'}
    ]
  },
  render: () ->
    return(
        <SideNav className={"sidenav"} itemType="lefticon" itemHeight="32px" navigation={this.state.nav}></SideNav>
    )
module.exports = SideNavComponent

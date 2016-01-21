React = require 'react'
shell = require 'shell'

SideNavComponent = require './SideNav'

class Main extends React.Component
  state: {
    message: 'Chiika'
  },
  elect: {
    electron: process.versions.electron,
    chrome:process.versions.chrome
  }
  constructor: () ->
    super()
  openGithub: () ->
    shell.openExternal('https://github.com/arkenthera/Chiika')
  renderSidenav: () ->
    return(<h2>Hehehe</h2>);
  render: () ->
    return (<div className="container">
    <div className="jumbotron main"><SideNavComponent/>
    <img src="../assets/images/chiika.png" alt=""></img>

    </div></div>)

module.exports =
  Main: Main

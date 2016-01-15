React = require 'react'
shell = require 'shell'

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
  render: () ->
    return (
      <div className="container">
        <div className="jumbotron main">
          <h1>{this.state.message}</h1>
          <img src="../assets/images/chiika.png" alt=""></img>
          <p>Built with Electron. Repo <a href="#" onClick={this.openGithub}>chiika<span className="glyphicon glyphicon-heart"></span></a></p>
          <p>Electron Version: <strong>{this.elect.electron}</strong>,Chrome Version: <strong>{this.elect.chrome}</strong></p>
        </div>
      </div>
    )

module.exports =
  Main: Main

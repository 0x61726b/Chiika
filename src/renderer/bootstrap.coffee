React = require 'react'
ReactDOM = require 'react-dom'
Main = require('./components/main').Main

ReactDOM.render(React.createElement(Main), document.getElementById('app'))
# React.render(<div>start</div>, document.getElementById('app'))

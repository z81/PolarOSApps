Todo = React.createClass
  displayName: 'Todo'
  getInitialState: ->
    hide: false
  close: ->
    @setState
      hide: true

  render: ->
      if @state.hide
        return null

      React.DOM.div classsName: 'todo',
        React.DOM.span null, @props.text,
        React.DOM.span onClick: @close, style: {float: 'right'}, '[x] '

Todos = React.createClass
  displayName: 'Todos'
  todos: (todos)->
      todos.map (t)-> Todo text: t

  render: ->
      React.DOM.div id:"todos", @todos @props.todos

Input = React.createClass
  displayName: 'Input'
  getInitialState: ->
      text: @props.text
  change: (e)->
      @setState
        text: e.target.value
  add: ->
      @props.add @state.text
      @setState
        text: ""
  render: ->
      React.DOM.div null,
        React.DOM.input value: @state.text,onChange: @change, null,
        React.DOM.button onClick: @add, 'Add'

App = React.createClass
  displayName: 'App'
  getInitialState: ->
      todos: ['first todo']
  add: (text)->
    @state.todos.push text
    @setState
      todos: @state.todos

  render: ->
      React.DOM.div null,
        Input(add: @add),
        Todos(todos: @state.todos)

React.renderComponent App(), document.getElementById('root')
`import StateMachine from 'asteroids/state-machine'`
`import State from 'asteroids/state'`

(->
  # Keyboard handling
  keys = []
  $(document).keydown((event) ->
    keys[event.which] = true
    event.preventDefault()
  )
  $(document).keyup((event) ->
    keys[event.which] = false
    event.preventDefault()
  )

  # Set the initial state
  state = new State('menu')

  gameLoop = (->
    # Handle state transitions
    if state.transition?
      console.debug("Transitioning to #{state.transition}")
      StateMachine.transitionTo(state.transition).then((newState) ->
        state = newState
        window.requestAnimationFrame(gameLoop)
      # If there was an error transitioning
      ,(err) ->
        console.error(err)
      )
    # Render the current state
    else
      state.render()
      state.handleInput(keys)
      window.requestAnimationFrame(gameLoop)
  )
  gameLoop()
)()

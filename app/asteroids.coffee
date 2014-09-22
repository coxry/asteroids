`import StateMachine from 'asteroids/state-machine'`

(->
  # Keyboard handling
  keys = []
  window.onkeydown = (event) ->
    keys[event.keyCode] = true
    return
  window.onkeyup = (event) ->
    keys[event.keyCode] = false
    return

  StateMachine.transitionTo('menu').then((state) ->
    gameLoop = (->
      state.render()
      state.handleInput(keys)

      # If there needs to be a transition then transition
      if state.transition?
        console.debug("Transitioning to #{state.transition}")
        StateMachine.transitionTo(state.transition).then((newState) ->
          state = newState
          window.requestAnimationFrame(gameLoop)
        )
      else
        window.requestAnimationFrame(gameLoop)
    )
    gameLoop()
  ,(err) ->
    console.error(err)
  )
)()

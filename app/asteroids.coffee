`import Utils from 'asteroids/utils'`
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

  # Load all of our images in a promise array.
  # Each image is a resolved promise.
  Promise.all([
    Utils.loadImage('./images/asteroid.png', 128, 128),
    Utils.loadImage('./images/ship.png', 22, 22)
  ]).then((images) ->

    # Transition to the menu state first
    state = StateMachine.transitionTo(
      'menu',
      $('#gameScreen').first(),
      images
    )

    # Game loop!
    gameLoop = (->
      state.render()
      state.handleInput(keys)

      # If there needs to be a transition then transition
      newState = state.transition
      state = StateMachine.transitionTo(
        newState,
        $('#gameScreen').first(),
        images
      ) if newState?

      # Let your browser decide when to run the loop again
      window.requestAnimationFrame(gameLoop)
    )
    gameLoop()

  # If there was an error loading images
  ,(err) ->
    console.error(err)
  )
)()

`import MenuState from 'asteroids/menu-state'`
`import GameState from 'asteroids/game-state'`

class StateMachine
  @transitionTo: (state) ->
    switch state
      when 'menu'
        stateClass = MenuState
      when 'game'
        stateClass = GameState

    state = new stateClass()

    new Promise((resolve, reject) ->
      state.setup().then((images) ->
        resolve(state)
      ,(err) ->
        reject(err)
      )
    )

`export default StateMachine`


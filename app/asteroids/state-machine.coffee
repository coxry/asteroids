`import MenuState from 'asteroids/menu-state'`
`import GameState from 'asteroids/game-state'`

class StateMachine
  @transitionTo: (state, canvas, images) ->
    switch state
      when 'menu'
        return new MenuState(canvas, images)
      when 'game'
        return new GameState(canvas, images)

`export default StateMachine`


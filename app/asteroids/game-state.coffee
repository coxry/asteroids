`import State from 'asteroids/state'`
`import Asteroid from 'asteroids/asteroid'`
`import Ship from 'asteroids/ship'`

class GameState extends State
  setup: ->
    super
    @asteroids = [1..2].map((i) =>
      new Asteroid(@images[0],
        Math.random() * 1000 % @cw,
        Math.random() * 1000 % @ch
      )
    )
    @entities = []
    Array.prototype.push.apply(@entities, @asteroids)
    @ship = new Ship(@images[1], @cw / 2, @ch / 2)

  render: ->
    super
    @ship.draw(@ctx)
    @ship.move(@fpsCounter.dt, @cw, @ch)

    # Fire the lazers
    bullet = @ship.fireBullet()
    @entities.push(bullet) if bullet?
    reapEntities = []

    # Draw the game
    for entity in @entities
      entity.draw(@ctx)
      entity.move(@fpsCounter.dt, @cw, @ch)
      if entity.collidesWith(@ship) and
        String(entity) is 'asteroid' then @transition = 'menu'
      reapEntities.push(entity) if entity.reap()

    # Remove bullets / other reaped entities
    for entity in reapEntities
      @entities.splice(@entities.indexOf(entity), 1)

  handleInput: (keys) ->
    @ship.setKeys(keys)

`export default GameState`

`import State from 'asteroids/state'`
`import Asteroid from 'asteroids/asteroid'`
`import Ship from 'asteroids/ship'`
`import Utils from 'asteroids/utils'`

class GameState extends State
  setup: ->
    super
    Promise.all([
      Utils.loadImage('./images/asteroid.png', 128, 128),
      Utils.loadImage('./images/ship.png', 22, 22)
    ]).then((images) =>
      @asteroids = [1..2].map((i) =>
        new Asteroid(images[0],
          Math.random() * 1000 % @cw,
          Math.random() * 1000 % @ch
        )
      )
      @entities = []
      Array.prototype.push.apply(@entities, @asteroids)
      @ship = new Ship(images[1], @cw / 2, @ch / 2)
    )

  render: ->
    super
    @ship.draw(@ctx)
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
    @ship.move(@fpsCounter.dt, @cw, @ch, keys)

    # Fire the lazers
    bullet = @ship.fireBullet(keys)
    @entities.push(bullet) if bullet?

`export default GameState`

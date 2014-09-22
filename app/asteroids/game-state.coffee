`import State from 'asteroids/state'`
`import Asteroid from 'asteroids/asteroid'`
`import Ship from 'asteroids/ship'`
`import Utils from 'asteroids/utils'`

class GameState extends State
  setup: ->
    super
    @entities = []
    @bullets = []

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

      if String(entity) is 'asteroid'
        if entity.collidesWith(@ship)
          @transition = 'menu'
          break
        else
          for bullet in @bullets
            if entity.collidesWith(bullet)
              console.debug('COLLIDE')

      reapEntities.push(entity) if entity.reap()

    # Remove bullets / other reaped entities
    for entity in reapEntities
      @bullets.splice(@bullets.indexOf(entity)) if String(entity) is 'bullet'
      @entities.splice(@entities.indexOf(entity), 1)

  handleInput: (keys) ->
    @ship.move(@fpsCounter.dt, @cw, @ch, keys)

    # Fire the lazers
    bullet = @ship.fireBullet(keys)
    if bullet?
      @bullets.push(bullet)
      @entities.push(bullet)

`export default GameState`

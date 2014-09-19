`import Ship from 'asteroids/ship'`
`import Asteroid from 'asteroids/asteroid'`
`import Utils from 'asteroids/utils'`
`import FpsCounter from 'asteroids/fps-counter'`

(->
  canvas = $('#gameScreen').first()
  ctx = canvas[0].getContext('2d')

  # Canvas width and height
  cw = parseInt(canvas.attr('width'))
  ch = parseInt(canvas.attr('height'))

  # Load all of our images in a promise array.
  # Each image is a resolved promise.
  Promise.all([
    Utils.loadImage('./images/asteroid.png', 128, 128),
    Utils.loadImage('./images/ship.png', 22, 22)
  ]).then((images) ->

    # Set initial state to setupMenu
    state = 'setupMenu'
    ship = null
    asteroids = []
    entities = []

    # The menu text fades in
    menuFont = "14pt 'Open Sans', sans-serif"
    menuTxt = 'Press space to start'
    ctx.font = menuFont
    menuTxtMeasure = ctx.measureText(menuTxt)
    fadeTick = 0

    # Keyboard handling
    keys = []
    window.onkeydown = (event) ->
      keys[event.keyCode] = true
      return
    window.onkeyup = (event) ->
      keys[event.keyCode] = false
      return

    # Count FPS in our game loop
    fpsCounter = new FpsCounter()

    # Game loop!
    gameLoop = (->
      fpsCounter.tick()

      # Calculate delay between frames
      dt = fpsCounter.dt

      # Clear the screen
      ctx.fillStyle = '#000000'
      ctx.clearRect(0, 0, cw, ch)

      # Drawn during menu state and playing state.
      # Move+draw asteroids, reap entities and check
      # for collision with ship
      drawGame = ->
        reapEntities = []
        for entity in entities
          if state is 'playing' and
            entity.collidesWith(ship) and
            String(entity) is 'asteroid' then state = 'setupMenu'
          entity.draw(ctx)
          entity.move(dt, cw, ch)
          reapEntities.push(entity) if entity.reap()

        # Remove bullets / other reaped entities
        for entity in reapEntities
          entities.splice(entities.indexOf(entity), 1)

      # Drawn during the playing state.
      drawShip = ->
        ship.draw(ctx)
        ship.move(dt, cw, ch)

        # Fire the lazers
        bullet = ship.fireBullet()
        entities.push(bullet) if bullet?

      switch state
        when 'setupMenu'
          keys = []
          asteroids = null
          ship = null
          asteroids = [1..5].map((i) ->
            new Asteroid(images[0],
              Math.random() * 1000 % cw, Math.random() * 1000 % ch)
          )
          entities = []
          Array.prototype.push.apply(entities, asteroids)
          state = 'menu'

        when 'menu'
          fadeTick += 0.0005 * dt if fadeTick < 1
          ctx.font = menuFont
          ctx.fillStyle = "rgba(200,200,200,#{fadeTick})"
          ctx.fillText(menuTxt, (cw - menuTxtMeasure.width) / 2, ch / 2)
          drawGame()
          # Space
          if keys[32]
            keys[32] = false
            state = 'setupPlaying'

        when 'setupPlaying'
          asteroids = [1..2].map((i) ->
            new Asteroid(images[0])
          )
          entities = []
          Array.prototype.push.apply(entities, asteroids)
          ship = new Ship(images[1], cw / 2, ch / 2)
          ship.setKeys(keys)
          state = 'playing'

        when 'playing'
          drawShip()
          drawGame()

      # Let your browser decide when to run the loop again
      window.requestAnimationFrame(gameLoop)
    )
    gameLoop()

  # If there was an error loading images
  ,(err) ->
    console.error(err)
  )
)()

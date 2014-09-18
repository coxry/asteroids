`import Ship from 'asteroids/ship'`
`import Asteroid from 'asteroids/asteroid'`

(->
  loadImage = (url, width, height) ->
    new Promise((resolve, reject) ->
      image = new Image()
      image.src = url
      image.width = width
      image.height = height
      image.onload = ->
        imageCanvas = document.createElement('canvas')
        imageCanvas.width = width
        imageCanvas.height = height
        imageCanvas.getContext('2d').drawImage(image, 0, 0)
        cleanup()
        resolve(imageCanvas)
      image.onerror = (err) ->
        cleanup()
        reject(Error("Unable to load #{url}"))
      cleanup = ->
        image.onload = null
        image.onerror = null
    )
  canvas = $('#gameScreen').first()
  ctx = canvas[0].getContext('2d')

  shipWidth = 22
  shipHeight = 22

  # Load all of our images in a promise array.
  # Each image is a resolved promise.
  Promise.all([
    loadImage('./images/asteroid.png', 128, 128),
    loadImage('./images/ship.png', shipWidth, shipHeight)
  ]).then((images) ->

    # Variables for handing FPS and dt
    frames = 0
    time = null
    oldTime = new Date().getTime()

    # Canvas width and height
    cw = parseInt(canvas.attr('width'))
    ch = parseInt(canvas.attr('height'))

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
    window.onkeyup = (event) ->
      keys[event.keyCode] = false

    # Game loop!
    gameLoop = (->
      now = new Date().getTime()
      dt = now - (time or now)
      time = now

      # Log FPS every second
      if time - oldTime > 1000
        oldTime = time
        console.debug(frames)
        frames = 0

      # Clear the screen
      ctx.fillStyle = '#000000'
      # ctx.fillRect(0, 0, cw, ch)
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
          ship = new Ship(images[1], cw / 2, ch / 2, shipWidth, shipHeight)
          ship.setKeys(keys)
          state = 'playing'

        when 'playing'
          drawShip()
          drawGame()

      frames = frames + 1
      # Let your browser decide when to run the loop again
      window.requestAnimationFrame(gameLoop)
    )
    gameLoop()

  # If there was an error loading images
  ,(err) ->
    console.error(err)
  )
)()

$(->
  class Entity
    velX: 0
    velY: 0
    x: 0
    y: 0

    move: (dt, maxWidth, maxHeight) ->
      @x += @velX * dt
      @y += @velY * dt
      if @x > maxWidth then @x = -@width
      if @x < -@width then @x = maxWidth
      if @y > maxHeight then @y = -@height
      if @y < -@height then @y = maxHeight

    collidesWith: (e) ->
      @x + (@width - @cWidth) / 2 < e.x + e.cWidth + (e.width - e.cWidth) / 2 + e.cOffX and
        @x + @cWidth + (@width - @cWidth) / 2 + @cOffX > e.x + (e.width - e.cWidth) / 2 + e.cOffX and
        @y + (@height - @cHeight) / 2 < e.y + e.cHeight + (e.height - e.cHeight) / 2 + e.cOffY and
        @y + @cHeight + (@height - @cHeight) / 2 + @cOffY > e.y + (e.height - e.cHeight) / 2 + e.cOffY

    reap: ->
      false

  class Bullet extends Entity
    # Width & height used for drawing
    width: 4
    height: 4
    # Colllision box width & height
    cWidth: 4
    cHeight: 4
    ticksTillReap: 500

    constructor: (x, y, velX, velY) ->
      @x = x - @width / 2
      @y = y - @height / 2
      @velX = velX
      @velY = velY

    reap: ->
      --@ticksTillReap < 0

    draw: (ctx) ->
      ctx.fillStyle = '#FFFFFF'
      ctx.fillRect(@x, @y, @width, @height)

    move: (dt) ->
      @x += @velX * dt
      @y += @velY * dt

    toString: ->
      'bullet'

  class Ship extends Entity
    # Width & height used for drawing
    width: 8
    height: 16
    # Colllision box width & height
    cWidth: 15
    cHeight: 10
    cOffX: -4
    cOffY: 0
    speed: 0.012
    bulletSpeed: 0.4
    rotation: 0
    maxSpeed: 1
    fireWait: 25
    color: '#FFFFFF'
    rotationSpeed: 0.0085
    keys: []

    constructor: (x, y) ->
      @fireTick = @fireWait
      @x = x
      @y = y

    setKeys: (keys) ->
      @keys = keys

    move: (dt, maxWidth, maxHeight) ->
      # Up
      if @keys[38]
        x = @velX - Math.cos(@rotation) * @speed
        y = @velY - Math.sin(@rotation) * @speed
        @velX = x
        @velY = y
        v = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2))
        if v > @maxSpeed
          scale = @maxSpeed / v
          @velX *= scale
          @velY *= scale
      # Left
      if @keys[37] then @rotation -= @rotationSpeed * dt
      # Right
      if @keys[39] then @rotation += @rotationSpeed * dt
      super(dt, maxWidth, maxHeight)

    fireBullet: ->
      # Wait until you can fire
      @fireTick = @fireTick + 1
      # Space
      if @keys[32] and @fireTick >= @fireWait
        @fireTick = 0
        xr = Math.cos(@rotation)
        yr = Math.sin(@rotation)
        new Bullet(@x - (@width + 2) * xr + @width / 2,
          @y - @height / 2 * yr + @height / 2,
          @velX + -xr * @bulletSpeed, @velY + -yr * @bulletSpeed)

    draw: (ctx) ->
      ctx.save()
      ctx.translate(@x,@y)
      # 2 for the lines on the spaceship
      ctx.translate(2, @height / 2)
      ctx.rotate(@rotation)
      ctx.translate(-2, -(@height / 2))
      ctx.beginPath()
      ctx.moveTo(@width, @height)
      ctx.lineTo(-@width, @height / 2)
      ctx.lineTo(@width, 0)
      ctx.closePath()
      ctx.strokeStyle = @color
      ctx.lineWidth = 1
      ctx.stroke()
      ctx.restore()
      ctx.strokeStyle = '#00FF00'
      ctx.strokeRect(@x + (@width - @cWidth) / 2 + @cOffX,
        @y + (@height - @cHeight) / 2 + @cOffY, @cWidth, @cHeight)

    toString: ->
      'ship'

  class Asteroid extends Entity
    cWidth: 100
    cHeight: 100
    cOffX: 2
    cOffY: 2

    constructor: (image, x, y)  ->
      @image = image
      @width = image.width
      @height = image.height
      @velX = Math.random() / 4 - Math.random() / 4
      @velY = Math.random() / 4 - Math.random() / 4
      @x = x or 0
      @y = y or 0
      @rotation = Math.random()
      @rotationSpeed = Math.random() / 800  - Math.random() / 800

    move: (dt, maxWidth, maxHeight) ->
      @rotation += @rotationSpeed * dt
      super(dt, maxWidth, maxHeight)

    draw: (ctx) ->
      ctx.save()
      ctx.translate(@x,@y)
      ctx.translate(@width / 2 + 2, @height / 2 + 2)
      ctx.rotate(@rotation)
      ctx.translate(-(@width / 2 + 2),-(@height / 2 + 2))
      ctx.drawImage(@image, 0, 0, @width, @height, 0, 0, @width, @height)
      ctx.restore()
      ctx.strokeStyle = '#FF0000'
      ctx.strokeRect(@x + (@width - @cWidth) / 2 + 2,
        @y + (@height - @cHeight) / 2 + 2, @cWidth, @cHeight)

    toString: ->
      'asteroid'

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

  # Load all of our images in a promise array.
  # Each image is a resolved promise.
  Promise.all([
    loadImage('./images/asteroid.png', 128, 128)
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
            new Asteroid(images[i % images.length],
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
          asteroids = [1..1].map((i) ->
            new Asteroid(images[i % images.length])
          )
          entities = []
          Array.prototype.push.apply(entities, asteroids)
          ship = new Ship(cw / 2, ch / 2)
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
)

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

    reap: ->
      false

  class Bullet extends Entity
    width: 4
    height: 4
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

  class Ship extends Entity
    width: 20
    height: 10
    speed: 0.012
    bulletSpeed: 0.4
    rotation: 0
    maxSpeed: 1
    fireWait: 25
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
        new Bullet(@x - @width * xr + @width / 2, @y - @width * yr,
          @velX + -xr * @bulletSpeed, @velY + -yr * @bulletSpeed)

    draw: (ctx) ->
      ctx.save()
      ctx.translate(@x,@y)
      # + 2 for the lines on the spaceship
      ctx.translate(@width / 2 + 2,0)
      ctx.rotate(@rotation)
      ctx.translate(-(@width / 2 + 2),0)
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.lineTo(@width,-@height)
      ctx.lineTo(@width,@height)
      ctx.closePath()
      ctx.strokeStyle = '#FFFFFF'
      ctx.lineWidth = 1
      ctx.stroke()
      ctx.restore()

  class Asteroid extends Entity
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
      ctx.drawImage(@image, 0, 0)
      ctx.restore()

  loadImage = (url) ->
    new Promise((resolve, reject) ->
      image = new Image()
      image.src = url
      image.onload = ->
        cleanup()
        resolve(image)
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
    loadImage('./images/asteroid.png')
  ]).then((images) ->

    # Variables for handing FPS and dt
    frames = 0
    time = null
    oldTime = new Date().getTime()

    # Canvas width and height
    cw = parseInt(canvas.attr('width'))
    ch = parseInt(canvas.attr('height'))

    # Set initial state to menu (press space to start)
    state = 'menu'

    # Setup some useful variables in the menu state
    ship = new Ship(canvas.attr('width') / 2, canvas.attr('height') / 2)
    asteroids = [1..5].map((i) ->
      new Asteroid(images[i % images.length],
        Math.random() * 1000 % cw, Math.random() * 1000 % ch)
    )
    entities = []
    Array.prototype.push.apply(entities, asteroids)
    # The text fades in
    txt = 'Press space to start'
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
      ctx.fillRect(0, 0, cw, ch)

      switch state
        when 'menu'
          fadeTick += 0.01 if fadeTick < 1
          ctx.font = "14pt 'Open Sans', sans-serif"
          ctx.fillStyle = "rgba(200,200,200,#{fadeTick})"
          ctx.fillText(txt, (cw - ctx.measureText(txt).width) / 2, ch / 2)
          # Space
          if keys[32]
            keys[32] = false
            state = 'leveldone'

        # Setup the next level
        when 'leveldone'
          asteroids = [1..5].map((i) ->
            new Asteroid(images[i % images.length])
          )
          entities = [ship]
          Array.prototype.push.apply(entities, asteroids)
          ship.setKeys(keys)
          state = 'playing'

      # Draw the game, move the entities which
      # are also drawn in the 'menu' state so I keep this
      # logic in here instead of just 'playing' state
      reapEntities = []
      for entity in entities
        entity.draw(ctx)
        entity.move(dt, cw, ch)
        reapEntities.push(entity) if entity.reap()

      for entity in reapEntities
        entities.splice(entities.indexOf(entity), 1)

      # Fire the lazers
      bullet = ship.fireBullet()
      entities.push(bullet) if bullet?

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

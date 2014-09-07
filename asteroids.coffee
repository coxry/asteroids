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

  class Ship extends Entity
    width: 20
    height: 10
    speed: 0.01

    constructor: (x, y) ->
      @x = x
      @y = y

    updateVelocity: (keys) ->
      # Up
      if keys[38] then @velY -= @speed
      # Down
      if keys[40] then @velY += @speed
      # Left
      if keys[37] then @velX -= @speed
      # Right
      if keys[39] then @velX += @speed

    draw: (ctx) ->
      ctx.save()
      ctx.translate(@x,@y)
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.lineTo(20,-10)
      ctx.lineTo(20,10)
      ctx.closePath()
      ctx.strokeStyle = '#FF0000'
      ctx.stroke()
      ctx.restore()

  class Asteroid extends Entity
    width: 100
    height: 100
    image: null

    constructor: (image, velX, velY) ->
      @image = image
      @velX = velX
      @velY = velY

    draw: (ctx) ->
      ctx.save()
      ctx.translate(@x,@y)
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
    loadImage('./images/asteroid1.png'),
    loadImage('./images/asteroid2.png'),
    loadImage('./images/asteroid3.png'),
    loadImage('./images/asteroid4.png')
  ]).then((images) ->

    # Setup some useful variables
    ship = new Ship(canvas.attr('width') / 2, canvas.attr('height') / 2)
    asteroids = [1..5].map((i) ->
      new Asteroid(images[i % 4],
        Math.random() / 2 - Math.random() / 2,
        Math.random() / 2 - Math.random() / 2)
    )
    entities = [ship]
    Array.prototype.push.apply(entities, asteroids)

    # Events for handling ship movement
    keys = []
    window.onkeydown = (event) ->
      keys[event.keyCode] = true
    window.onkeyup = (event) ->
      keys[event.keyCode] = false

    # Variables for handing FPS and dt
    frames = 0
    time = null
    oldTime = new Date().getTime()

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
      cw = parseInt(canvas.attr('width'))
      ch = parseInt(canvas.attr('height'))
      ctx.fillRect(0, 0, cw, ch)

      ship.updateVelocity(keys)

      # Draw the game + move the entities
      for entity in entities
        entity.draw(ctx)
        entity.move(dt, cw, ch)

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

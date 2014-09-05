$(->
  class Entity
    velX: 0
    velY: 0
    x: 0
    y: 0

    tick: (maxWidth, maxHeight) ->
      @x += @velX
      @y += @velY
      if @x > maxWidth then @x = -@width / 2
      if @x < -@width / 2 then @x = maxWidth
      if @y > maxHeight then @y = -@height / 2
      if @y < -@height / 2 then @y = maxHeight

  class Ship extends Entity
    width: 20
    height: 10

    constructor: (x, y) ->
      @x = x
      @y = y

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

  canvas = $('#gameScreen')[0]
  ctx = canvas.getContext('2d')

  window.onresize = -> resizeCanvas()

  resizeCanvas = ->
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight


  # Load all of our images in a promise array.
  # Each image is a resolved promise.
  Promise.all([
    loadImage('./images/asteroid1.png'),
    loadImage('./images/asteroid2.png'),
    loadImage('./images/asteroid3.png'),
    loadImage('./images/asteroid4.png')
  ]).then((images) ->

    resizeCanvas()
    # Setup some useful variables
    ship = new Ship(window.innerWidth / 2, window.innerHeight / 2)
    asteroids = [1..100].map((i) ->
      new Asteroid(images[i % 4],
        Math.random() * 10 - Math.random() * 10,
        Math.random() * 10 - Math.random() * 10)
    )
    entities = [ship]
    Array.prototype.push.apply(entities, asteroids)

    # Game loop!
    setInterval(->
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      for entity in entities
        entity.draw(ctx)
        entity.tick(canvas.width, canvas.height)
    ,10)
  ,(err) ->
    console.error(err)
  )
)

$ ->

  class Entity
    velX: 0
    velY: 0
    x: 0
    y: 0

    tick: (maxWidth, maxHeight) ->
      @x += @velX
      @y += @velY
      if @x > maxWidth then @x = -@width/2
      if @x < -@width/2 then @x = maxWidth
      if @y > maxHeight then @y = -@height/2
      if @y < -@height/2 then @y = maxHeight

    draw: () ->

  class Ship extends Entity
    width: 20
    height: 10

    constructor: (x, y)->
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

    constructor: (image, velX, velY)->
      @image = image
      @velX = velX
      @velY = velY

    draw: (ctx) ->
      ctx.save()
      ctx.translate(@x,@y)
      ctx.drawImage(@image, 0, 0)
      ctx.restore()

  $.loadImage = (url) ->
    $.Deferred((deferred) ->
      image = new Image()
      image.src = url
      image.onload = () ->
        cleanup()
        deferred.resolve(image)
      image.onerror = (err) ->
        cleanup()
        deferred.reject("Unable to load #{url}")
      cleanup = () ->
        image.onload = null
        image.onerror = null
    ).promise()

  $.whenall = (arr) ->
    $.when.apply($, arr).then(->
      Array.prototype.slice.call(arguments)
    )

  # Load all of our images in a promise array.
  # Each image is a resolved promise.
  $.whenall([
    $.loadImage('./images/asteroid1.png'),
    $.loadImage('./images/asteroid2.png'),
    $.loadImage('./images/asteroid3.png'),
    $.loadImage('./images/asteroid4.png')
  ]).done((images) ->

    # Setup some useful variables
    canvas = $('#gameScreen')[0]
    ctx = canvas.getContext('2d')
    ship = new Ship(window.innerWidth/2, window.innerHeight/2)
    asteroids = [1..100].map((i) ->
      new Asteroid(images[i%4],
        Math.random()*10 - Math.random()*10,
        Math.random()*10 - Math.random()*10)
    )
    entities = [ship]
    Array.prototype.push.apply(entities, asteroids)

    # Game loop!
    setInterval((=>
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      for entity in entities
        entity.draw(ctx)
        entity.tick(window.innerWidth, window.innerHeight)
    ),10)

  ).fail((err) ->
    console.error err
  )

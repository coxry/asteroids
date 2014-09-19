`import GameEntity from 'asteroids/game-entity'`
`import Bullet from 'asteroids/bullet'`

class Ship extends GameEntity
  # Width & height used for drawing
  # Colllision box width & height
  cWidth: 15
  cHeight: 10
  cOffX: 0
  cOffY: 0
  speed: 0.012
  bulletSpeed: 0.4
  rotation: 0
  maxSpeed: 1
  fireWait: 25
  color: '#FFFFFF'
  rotationSpeed: 0.0085
  keys: []

  constructor: (image, x, y) ->
    @image = image
    @fireTick = @fireWait
    @x = x
    @y = y
    @width = image.width
    @height = image.height

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
      new Bullet(@x - @width * xr + @width / 2,
        @y - @height * yr + @height / 2,
        @velX + -xr * @bulletSpeed,
        @velY + -yr * @bulletSpeed)

  draw: (ctx) ->
    ctx.save()
    ctx.translate(@x,@y)
    ctx.translate(@width / 2 + 2, @height / 2)
    ctx.rotate(@rotation)
    ctx.translate(-(@width / 2 + 2),-(@height / 2))
    ctx.drawImage(@image, 0, 0)
    ctx.restore()
    # ctx.strokeStyle = '#00FF00'
    # ctx.strokeRect(@x + (@width - @cWidth) / 2 + @cOffX,
      # @y + (@height - @cHeight) / 2 + @cOffY, @cWidth, @cHeight)

  toString: ->
    'ship'

`export default Ship`

`import GameEntity from 'asteroids/game-entity'`

class Asteroid extends GameEntity
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
    ctx.translate(@width / 2 + 2, @height / 2)
    ctx.rotate(@rotation)
    ctx.translate(-(@width / 2 + 2),-(@height / 2))
    ctx.drawImage(@image, 0, 0, @width, @height, 0, 0, @width, @height)
    ctx.restore()
    # ctx.strokeStyle = '#FF0000'
    # ctx.strokeRect(@x + (@width - @cWidth) / 2 + 2,
      # @y + (@height - @cHeight) / 2 + 2, @cWidth, @cHeight)

  toString: ->
    'asteroid'

`export default Asteroid`

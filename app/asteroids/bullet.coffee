`import GameEntity from 'asteroids/game-entity'`

class Bullet extends GameEntity
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

`export default Bullet`

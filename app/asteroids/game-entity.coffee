class GameEntity
  velX : 0
  velY : 0
  x    : 0
  y    : 0

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

`export default GameEntity`

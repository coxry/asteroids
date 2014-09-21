`import State from 'asteroids/state'`
`import Asteroid from 'asteroids/asteroid'`

class MenuState extends State
  setup: ->
    super
    @asteroids = null
    @fadeTick  = 0
    @menuFont  = "14pt 'Open Sans', sans-serif"
    @menuTxt   = 'Press space to start'
    @ctx.font = @menuFont
    @menuTxtMeasure = @ctx.measureText(@menuTxt)
    @asteroids = [1..5].map((i) =>
      new Asteroid(@images[0],
        Math.random() * 1000 % @cw,
        Math.random() * 1000 % @ch)
    )

  render: ->
    super
    @fadeTick += 0.0005 * @fpsCounter.dt if @fadeTick < 1
    @ctx.fillStyle = "rgba(200,200,200,#{@fadeTick})"
    @ctx.fillText(@menuTxt, (@cw - @menuTxtMeasure.width) / 2, @ch / 2)
    for asteroid in @asteroids
      asteroid.draw(@ctx)
      asteroid.move(@fpsCounter.dt, @cw, @ch)

  handleInput: (keys) ->
    if keys[32]
      keys[32] = false
      @transition = 'game'

`export default MenuState`

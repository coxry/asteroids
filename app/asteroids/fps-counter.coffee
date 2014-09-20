class FpsCounter
  fps    : 0
  frames : 0
  dt     : 0

  constructor: ->
    @oldTime = new Date().getTime()

  tick: ->
    @now  = new Date().getTime()
    @dt   = @now - (@time or @now)
    @time = @now
    if @time - @oldTime > 1000
      @oldTime = @time
      @fps = @frames
      console.debug(@fps)
      @frames = 0
    @frames = @frames + 1

`export default FpsCounter`

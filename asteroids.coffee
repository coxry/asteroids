$(->
  $.loadImage = (url) ->
    $.Deferred((deferred) ->
      image = new Image()
      image.src = url
      image.onload = () ->
        deferred.resolve(image)
      image.onerror = () ->
        deferred.reject("Unable to load #{url}")
    ).promise()

  $.whenall = (arr) ->
    $.when.apply($, arr).then(->
      Array.prototype.slice.call(arguments)
    )

  $.whenall([
    $.loadImage('./images/asteroid1.png'),
    $.loadImage('./images/asteroid2.png'),
    $.loadImage('./images/asteroid3.png'),
    $.loadImage('./images/asteroid4.png')
  ]).done((images) ->
    console.debug images
    canvas = $('#gameScreen')[0]
    ctx = canvas.getContext('2d')
    setInterval((->
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
      ctx.fillRect(0,0,canvas.width,canvas.height)
      i=0
      for image in images
        ctx.drawImage(image, 100 * i, 0)
        i++
    ),1000)
  ).fail((err) ->
    console.error err
  )
)

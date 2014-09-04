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

  $.loadImages = (arr) ->
    $.Deferred((deferred) ->
      images = []
      for url in arr
        $.loadImage(url).then((image) ->
          images.push(image)
          if images.length == arr.length
            deferred.resolve(images)
        ).fail((err) ->
          deferred.reject(err)
        )
    ).promise()

  $.loadImages([
    './images/asteroid1.png',
    './images/asteroid2.png',
    './images/asteroid3.png'
  ]).then((images) ->
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
    console.debug err
  )
)

class Utils
  @cache = {}

  @loadImage: (url, width, height) =>
    new Promise((resolve, reject) =>
      if @cache[url]
        resolve(@cache[url])
        return
      image = new Image()
      image.src = url
      image.width = width if width?
      image.height = height if height?
      image.onload = =>
        imageCanvas = document.createElement('canvas')
        imageCanvas.width = width
        imageCanvas.height = height
        imageCanvas.getContext('2d').drawImage(image, 0, 0)
        @cache[url] = imageCanvas
        cleanup()
        resolve(imageCanvas)
      image.onerror = (err) ->
        cleanup()
        reject(Error("Unable to load #{url}"))
      cleanup = ->
        image.onload = null
        image.onerror = null
    )

`export default Utils`

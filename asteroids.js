// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    $.loadImage = function(url) {
      return $.Deferred(function(deferred) {
        var image;
        image = new Image();
        image.src = url;
        image.onload = function() {
          return deferred.resolve(image);
        };
        return image.onerror = function() {
          return deferred.reject("Unable to load " + url);
        };
      }).promise();
    };
    $.whenall = function(arr) {
      return $.when.apply($, arr).then(function() {
        return Array.prototype.slice.call(arguments);
      });
    };
    return $.whenall([$.loadImage('./images/asteroid1.png'), $.loadImage('./images/asteroid2.png'), $.loadImage('./images/asteroid3.png'), $.loadImage('./images/asteroid4.png')]).done(function(images) {
      var canvas, ctx;
      console.debug(images);
      canvas = $('#gameScreen')[0];
      ctx = canvas.getContext('2d');
      return setInterval((function() {
        var i, image, _i, _len, _results;
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        i = 0;
        _results = [];
        for (_i = 0, _len = images.length; _i < _len; _i++) {
          image = images[_i];
          ctx.drawImage(image, 100 * i, 0);
          _results.push(i++);
        }
        return _results;
      }), 1000);
    }).fail(function(err) {
      return console.error(err);
    });
  });

}).call(this);

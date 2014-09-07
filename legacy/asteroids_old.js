	//var FPS=32;
	


	var START_ASTEROIDS=5;
	var START_ASTEROID_RADIUS=40;
	var NUMBER_OF_SPLITS=3;
	var ASTEROIDS_PER_ASTEROID=Math.pow(2,NUMBER_OF_SPLITS);
	var MIN_ASTEROID_RADIUS=START_ASTEROID_RADIUS/ASTEROIDS_PER_ASTEROID;
	var leftKey=false; rightKey=false; upKey=false; spaceBar=false;
	var score=0;
	var ship;
	var missles;
	var asteroids;
	var canvas=null;
	var ctx;
	var asteroidImg;
	var drawInterval = 31;
	var frameCount = 0;
	var fps = 0;
	var maxfps = 1 / (drawInterval / 1000);
	var lastTime = new Date();
	var asteroidImg = new Array(3);
	function Coordinate(x,y) {
		this.x=x;
		this.y=y
	}
	function Ship() {
		this.maxSpeed = 10;
		this.speed=new Coordinate(0,0);
		this.position=new Coordinate(0,0);
		this.size=new Coordinate(20,7);
		this.shootSpeed=2;
		this.color="lime";
		this.fireOutColor="orange";
		this.fireInColor="yellow";
		this.rotation=0;
		this.animation=0;
	}
	function Missle() {
		this.speed=new Coordinate(0,0);
		this.position=new Coordinate(0,0);
		this.radius=1.5;
		this.color="white";
		this.frame=0;
	}
	function Asteroid() {
		this.speed=new Coordinate(0,0);
		this.position=new Coordinate(0,0);
		this.radius=START_ASTEROID_RADIUS;
		this.color="gray";
	}
	// Called after the HTML body loads
	function init() {
		loadAsteroidImages(1);
		canvas = document.getElementById("gameScreen");
		ctx = canvas.getContext("2d");
		initLevel();
		window.addEventListener("resize",setupCanvas,false);
		document.addEventListener("keydown", keyDown, false);
		document.addEventListener("keyup", keyUp, false);
		setInterval(mainLoop, drawInterval);
		
	}
	function loadAsteroidImages(num) {
		if (num <= 4) {
			asteroidImg[num] = new Image();
			asteroidImg[num].src = "./images/asteroid"+num+".png";
			asteroidImg[num].onload = loadAsteroidImages(num+1);
		}
	}
	function initLevel() {
		missles=[];
		asteroids=[];
		ship = new Ship();
		score=0;
		setupCanvas();
		ship.position.x=canvas.width/2;
		ship.position.y=canvas.height/2;
		generateAsteroids();
	}
	
	function shipCrashed() {
	initLevel();
	}
	
    function setupCanvas() {
		// TODO replace with modernizr, show error on else
		if( ctx != null ) {
		canvas.width = window.innerWidth;
		canvas.height = window.innerHeight;
	} else {
			document.write("Unable to setup canvas.. Are you using IE?");
		}
     }
	
	function mainLoop() {
		var nowTime = new Date();
		var diffTime = Math.ceil((nowTime.getTime() - lastTime.getTime()));
		if (diffTime >= 1000) {
			fps = frameCount;
			frameCount = 0.0;
			lastTime = nowTime;
		}
			
          ctx.fillStyle = "black";
          ctx.fillRect(0, 0, canvas.width, canvas.height );
          
         // Draws the game to the screen
		animateShip();
		animateMissles();
		animateAsteroids();
		drawScore();
		//drawFPS();
			  
          // Sets the speed, position and existance of user controlled entities
         checkKeys();
		 frameCount++;
	}
	
	function checkKeys() {
		if (spaceBar) {
			generateMissle();
		}
		if (rightKey) {
			ship.rotation+=0.174532925;
		}
		if (leftKey) {
			ship.rotation-=0.174532925;
		}
		if (upKey) {
			accelerateShip();
		} else {
			ship.animation = 0;
		}
	}
	
	function handleKey(keyCode, down) {
	switch(keyCode) {
			// left
			case 37:
				leftKey=down;
				break;
			case 65:
				leftKey=down;
				break;
			// right
			case 39:
				rightKey=down;
				break;
			case 68:
				rightKey=down;
				break;
			// up
			case 38:
				upKey=down;
				break;
			case 87:
				upKey=down;
				break;
			// space bar
			case 32:
				spaceBar=down;
				break;
		}
	}
	
	function keyDown(evt) {
	handleKey(evt.keyCode,true);
	}
	
	function keyUp(evt) {
	handleKey(evt.keyCode,false);
	}
	
	function accelerateShip() {
		if (Math.abs(ship.speed.x - Math.cos(ship.rotation)) < ship.maxSpeed)
			ship.speed.x -= Math.cos(ship.rotation)*0.3;
		if (Math.abs(ship.speed.y - Math.sin(ship.rotation)) < ship.maxSpeed)
			ship.speed.y -= Math.sin(ship.rotation)*0.3;
		
		if (ship.animation == 0 || ship.animation == 7) ship.animation = 1;
		else if (ship.animation == 1) ship.animation = 5;
		else if (ship.animation == 5) ship.animation = 7;
	}
	
	function animateShip() {
         drawShip();
	
		var newX = ship.position.x + ship.speed.x;
		var newY = ship.position.y + ship.speed.y;
		
	if (newX > canvas.width) {
			newX = 0;
		} else if (newX < 0) {
			newX = canvas.width;
		}
		if (newY > canvas.height) {
			newY = 0;
		} else if (newY < 0) {
			newY = canvas.height;
		}

         ship.position.x = newX;
         ship.position.y = newY;
     }
	
	function animateMissles() {
		for (var i=0; i<missles.length; i++) {
			var missle = missles[i];
			if (missle.frame > 1) drawMissle(missle);
			missle.position.x += missle.speed.x;
			missle.position.y += missle.speed.y;
			
			if (missle.position.x > canvas.width || missle.position.y > canvas.height) missles.splice(i,1);
			if (missle.position.x < 0 || missle.position.y < 0) missles.splice(i,1);
			missle.frame += 1;
		}
	}
	
	function animateAsteroids() {
		for (var i=0; i<asteroids.length; i++) {
			var asteroid = asteroids[i];
			asteroid.position.x += asteroid.speed.x;
			asteroid.position.y += asteroid.speed.y;
			
			if (asteroid.position.x > canvas.width) asteroid.position.x = 0;
			if (asteroid.position.y > canvas.height) asteroid.position.y = 0;
			if (asteroid.position.x < 0) asteroid.position.x = canvas.width;
			if (asteroid.position.y < 0) asteroid.position.y = canvas.height;
			
			var curAx = asteroid.position.x;
			var curAy = asteroid.position.y;
			var curAr = asteroid.radius;
			
			if (shipCollision(curAx, curAy, curAr)){
				shipCrashed();
			}
			drawAsteroid(asteroid);
			
			for (var a=0; a<missles.length; a++) {
				var missle = missles[a];
				var curMx = missle.position.x;
				var curMy = missle.position.y;
				if (curAx+curAr-missle.radius >= curMx && curAx-curAr <= curMx+missle.radius) {
					if (curAy+curAr-missle.radius >= curMy && curAy-curAr <= curMy+missle.radius) {
						missles.splice(a,1);
						a--;
						if (asteroid.radius > MIN_ASTEROID_RADIUS) {
							var newAr = curAr/2;
							var newAx = curAx-(asteroid.radius/2)-Math.random()*2;
							var newAy = curAy-(asteroid.radius/2)-Math.random()*2;
							asteroid.radius = newAr;
							asteroid.position.x += (asteroid.radius/2)+Math.random()*2;
							asteroid.position.y += (asteroid.radius/2)+Math.random()*2;
							asteroid.speed.x += Math.random()*9 + Math.random()*-9;
							asteroid.speed.y += Math.random()*9 + Math.random()*-9;
							generateAsteroid(newAr,newAx,newAy);
							score+= 1;
						} else {
							asteroids.splice(i,1);
							score+= 2;
							i--;
						}
						break;
					}
				}
			}
		}
	}
	
	function shipCollision(asteroidX, asteroidY, asteroidRadius) {
		if (asteroidX+asteroidRadius >= ship.position.x && asteroidX-asteroidRadius <= ship.position.x+ship.size.x) {
			if (asteroidY+asteroidRadius >= ship.position.y && asteroidY-asteroidRadius <= ship.position.y+ship.size.y) {
				return true;
			}
		}
		return false;
	}
	
	function generateMissle() {
		var missle = new Missle();
		
		missle.position.x=ship.position.x+ship.size.x/2;
		missle.position.y=ship.position.y;
		missle.speed.x = Math.cos(ship.rotation)*-8 + ship.speed.x;
		missle.speed.y = Math.sin(ship.rotation)*-8 + ship.speed.y;
		missle.frame=0;
		missle.color="white";
		
		missles.push(missle);
	}
	
	function generateAsteroids() {
		for (var i=0; i<START_ASTEROIDS; i++) {
			
			var radius = START_ASTEROID_RADIUS;
			do {
				var x = Math.random()*canvas.width;
				var y = Math.random()*canvas.height;
				if (!shipCollision(x,y,radius)) {
					generateAsteroid(radius,x,y);
				}
			} while(shipCollision(x,y,radius));
		}
	}
	
	function generateAsteroid(radius, x, y) {
		asteroid = new Asteroid();
		asteroid.position.x = x;
		asteroid.position.y = y;
		asteroid.speed.x = Math.random()*9 + Math.random()*-9;
		asteroid.speed.y = Math.random()*9 + Math.random()*-9;
		asteroid.radius = radius;
		var i = 1+Math.round(Math.random()*3);
		asteroid.image = asteroidImg[i];
		asteroids.push(asteroid);
	}
	
	function drawMissle(missle) {
		ctx.save();
			ctx.translate(missle.position.x, missle.position.y);
			ctx.beginPath();
			ctx.arc(0,0,missle.radius,0,Math.PI*2,true);
			ctx.fillStyle = missle.color;
			ctx.fill();
			ctx.restore();
	}
	function drawAsteroid(asteroid) {
			ctx.save();
			ctx.translate(asteroid.position.x, asteroid.position.y);
			ctx.beginPath();
			//ctx.arc(0,0,asteroid.radius,0,Math.PI*2,true);
			ctx.drawImage(asteroid.image,0,0,asteroid.radius*2,asteroid.radius*2);
			ctx.strokeStyle = asteroid.color;
			ctx.stroke();
			ctx.restore();
	}
	
	function drawShip() {
		ctx.save();
		ctx.translate(ship.position.x,ship.position.y);
		
		// Rotate the ship
		ctx.translate(ship.size.x/2,0);
		ctx.rotate(ship.rotation);
		ctx.translate(ship.size.x/-2,0);
		
		// Draw the ship
		ctx.beginPath();
		ctx.moveTo(0,0);
		ctx.lineTo(ship.size.x,-ship.size.y);
		ctx.lineTo(ship.size.x,+ship.size.y);
		ctx.closePath();
		ctx.strokeStyle = ship.color;
		ctx.stroke();

		// Fire
		if (ship.animation > 0) {
			ctx.beginPath();
			ctx.moveTo(ship.size.x+18+ship.animation,0);
			ctx.lineTo(ship.size.x+2,-(ship.size.y-2));
			ctx.lineTo(ship.size.x+2,ship.size.y-2);
			ctx.closePath();
			ctx.fillStyle = ship.fireOutColor;
			ctx.fill();
			
			ctx.beginPath();
			ctx.moveTo(ship.size.x+10+ship.animation,0);
			ctx.lineTo(ship.size.x+4,-(ship.size.y-4));
			ctx.lineTo(ship.size.x+4,ship.size.y-4);
			ctx.closePath();
			ctx.fillStyle = ship.fireInColor;
			ctx.fill();
		}
		ctx.restore();
	}
	
	function drawFPS() {
		ctx.font = "bold 12px sans-serif"; 
		ctx.textBaseline = "top";
		ctx.textAlign  = "left";
		ctx.fillStyle = "white";
		ctx.fillText('FPS: ' + fps, 5, 5); 
	}
	
	function drawScore() {
	ctx.font = "bold 12px sans-serif"; 
	ctx.textBaseline = "top";
	ctx.textAlign  = "right";
	ctx.fillStyle = "white";
	ctx.fillText("Score:  "+score, canvas.width-5, 5); 
     }
     
     function randomHexColor() {
         var rint = Math.round(0xffffff * Math.random());
         return ('#0' + rint.toString(16)).replace(/^#0([0-9a-f]{6})$/i, '#$1');
     }
 

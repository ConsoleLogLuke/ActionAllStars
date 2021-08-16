package com.sdg.control
{
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderObject;
	import com.sdg.model.RoomLayerType;
	import com.sdg.simulation.GeneralTrajectory;
	import com.sdg.view.IRoomView;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	
	public class FlyBallGameController extends CairngormEventController implements IDynamicController
	{
		private var _roomContainer:IRoomView;
		private var _player:Object;
		private var _glove:Object;
		private var _hud:Object;
		private var _background:Object;
		private var _ballClass:Class;
		private var _ballShadowClass:Class;
		private var _hitSound:Sound;
		private var _catchSound:Sound;
		private var _crowdCheerSound:Sound;
		private var _channel:SoundChannel;
		private var catchGameIsOn:Boolean;
		private var gloveInitX:Number;
		private var gloveInitY:Number;
		
		public function FlyBallGameController(roomContainer:IRoomView, data:Object)
		{
			super();
			
			_roomContainer = roomContainer;
			_player = data.player;
			_glove = data.glove;
			_hud = data.hud;
			_background = data.background;
			_ballClass = data.ballClass;
			_ballShadowClass = data.ballShadowClass;
			_hitSound = data.hitSound;
			_catchSound = data.catchSound;
			_crowdCheerSound = data.crowdCheerSound;
			
			catchGameIsOn = false;
			_hud.visible = false;
			_hud.mouseEnabled = false;
			_glove.scaleX = _glove.scaleY = 0.6;
			gloveInitX = _glove.x;
			gloveInitY = _glove.y;
			
			// add the hud as a render object to the foreground render layer
			var rd:RenderData = new RenderData(MovieClip(_hud));
			var ro:RenderObject = new RenderObject(rd);
			_roomContainer.getRenderLayer(RoomLayerType.FOREGROUND).addItem(ro);
			
			_player.addEventListener(MouseEvent.ROLL_OVER, playerRollOver);
			_player.addEventListener(MouseEvent.ROLL_OUT, playerRollOut);
			_player.addEventListener(MouseEvent.CLICK, playerFirstClick);
			
		}
		
		public function init():void
		{
			
		}
		
		public function destroy():void
		{
			// remove listeners
			_player.removeEventListener(MouseEvent.ROLL_OVER, playerRollOver);
			_player.removeEventListener(MouseEvent.ROLL_OUT, playerRollOut);
			_player.removeEventListener(MouseEvent.CLICK, playerFirstClick);
		}
		
		
		// PLAYER EVENT HANDLERS
		private function playerRollOver(e:MouseEvent):void
		{
			Object(_player).showSpeechBubble();
		}
		private function playerRollOut(e:MouseEvent):void
		{
			Object(_player).hideSpeechBubble();
		}
		
		private function playerFirstClick(e:MouseEvent):void
		{
			// start the catch game
			
			// designate variables that will be used for the catch game
			var gBTmr:Timer;
			
			// remove the first click listener
			_player.removeEventListener(MouseEvent.CLICK, playerFirstClick);
			
			// remove mousr over and out listeners from player
			_player.removeEventListener(MouseEvent.ROLL_OVER, playerRollOver);
			_player.removeEventListener(MouseEvent.ROLL_OUT, playerRollOut);
			
			// hide the speech bubble above the player
			_player.hideSpeechBubble();
			
			if (catchGameIsOn == true)
			{
				gBTmr.removeEventListener(TimerEvent.TIMER, gBTmrInt);
				gBTmr.reset();
						
				// hide the catch game board
				_hud.alpha = 1;
						
				// reset some animations on the game board
				_hud.Fireworks.gotoAndPlay('idle');
			}
			else
			{
				// make the gameboard visible with an alpha of 0
				// so we can fade it in
				_hud.alpha = 0;
				_hud.visible = true;
			}
			
			// set boolean switch
			// true if catch game is taking place
			catchGameIsOn = true;
			
			// designate variables that will be used in the catch game
			var ball:MovieClip;
			var caughtBall:MovieClip;
			var shadow:MovieClip;
			var speed:Number; // overall speed
			var ballZ:Number;
			var xI:Number; // screen x initial
			var yI:Number; // screen y initial
			var zI:Number; // screen z initial
			var fieldAngle:Number;
			var rightToLeftAngle:Number;
			var ballInitOffsetX:Number;
			var ballInitOffsetY:Number;
			var gloveMinY:Number = 80;
			var gloveMaxY:Number = 600;
			var ballHitGround:Boolean;
			var hitLimit:int = 10;
			var hitLimitReached:Boolean = false;
			
			// x initial
			var simXI:Number;
			// y initial
			var simYI:Number;
			// acceleration x
			var aX:Number = 0;
			// acceleration y
			var aY:Number = GeneralTrajectory.GRAVITY;
			// initial velocity x
			var v0X:Number;
			// initial velocity y
			var v0Y:Number;
			
			// add interaction listeners
			//addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_roomContainer.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			// listen for an event on the NPC animation
			// we want to do something right when the NPC is hitting the ball
			_player.addEventListener(_player.HIT_INSTANCE, playerHitBall);
			
			// store an offset of where the mouse is in relation to the glove
			// we do this so that we can drag it by the same point that it was clicked at
			//var mGOffSetX:Number = _glove.x - _background.mouseX;
			var mGOffSetX:Number = 0;
			//var mGOffSetY:Number = _glove.y - _background.mouseY;
			var mGOffSetY:Number = 0;
			
			// set the offset of the position of the NPC to where the baseball would be hit by the NPC's bat
			ballInitOffsetX = 84;
			ballInitOffsetY = 65;
			
			// make a timer
			// we will use this to move the ball on an interval
			var tmr:Timer = new Timer(20);
			// listen for interval events on the timer
			tmr.addEventListener(TimerEvent.TIMER, timer);
			
			// create another timer
			// used to remove a caught ball after a period of time
			var tmr2:Timer = new Timer(2000);
			
			// create another timer
			// used to have a delay before fly balls are hit at the beggining of a game
			var startHittingDelay:Timer = new Timer(3000);
			startHittingDelay.addEventListener(TimerEvent.TIMER, hitDelay);
			
			// create another timer
			// used to make the glove pulsate
			var glovePulseTimer:Timer = new Timer(5);
			var glovePulseCount:int = 0;
			var glovePulseLength:int = 25;
			var pulseIncrement:Number = 0.01;
			glovePulseTimer.addEventListener(TimerEvent.TIMER, glovePulseInterval);
			glovePulseTimer.start();
			
			// set status of the game board
			_hud.Status = 'To <font color="#ffffff">exit</font> the game <font color="#ffffff">early</font>, click the button on your mouse.';
			
			// set catches and hits on the game board
			_hud.Hits = 0;
			_hud.Catches = 0;
			
			// create another timer
			// used to fade in the catch game hud
			var fadeInTimer:Timer = new Timer(10);
			fadeInTimer.addEventListener(TimerEvent.TIMER, fadeInInterval);
			fadeInTimer.start();
			
			// hide the mouse
			_roomContainer.hideCustomCursor = true;
			
			// scale up baseball glove
			_glove.scaleX = _glove.scaleY = 1;
			
			// open the glove
			_glove.gotoAndStop('idle');
			
			// start the hit delay timer
			// when it hits it's interval the fly balls will start
			startHittingDelay.start();
			
			
			function mouseMove(e:MouseEvent):void
			{
				// drag the glove around
				// use offset so that we can drag it by the same point that it was clicked at
				var gY:Number = _background.mouseY + mGOffSetY; // glove y
				gY = Math.max(gY, gloveMinY);
				gY = Math.min(gY, gloveMaxY);
				//glove.x = mouseX + mGOffSetX;
				_glove.x = _background.mouseX;
				_glove.y = gY;
			}
			function glovePulseInterval(e:TimerEvent):void
			{
				var timerCount:int = glovePulseTimer.currentCount;
				if (timerCount >= glovePulseLength)
				{
					glovePulseTimer.reset();
					glovePulseCount++;
					pulseIncrement *= -1;
					glovePulseTimer.start();
				}
				
				if (glovePulseCount == 6)
				{
					glovePulseTimer.removeEventListener(TimerEvent.TIMER, glovePulseInterval);
					glovePulseTimer.reset();
				}
				
				var newScale:Number = _glove.scaleX + pulseIncrement;
				_glove.scaleX = _glove.scaleY = newScale;
			}
			function fadeInInterval(e:TimerEvent):void
			{
				if (_hud.alpha >= 1)
				{
					fadeInTimer.removeEventListener(TimerEvent.TIMER, fadeInInterval);
					fadeInTimer.reset();
					return;
				}
				
				_hud.alpha += 0.02;
			}
			function hitDelay(e:TimerEvent):void
			{
				startHittingDelay.removeEventListener(TimerEvent.TIMER, hitDelay);
				startHittingDelay.reset();
				
				// add another click listener
				_roomContainer.addEventListener(MouseEvent.CLICK, gloveSecondClick);
			
				// play the npc animation of the player hitting the ball
				_player.gotoAndPlay("swingBat");
			}
			function gloveSecondClick(e:MouseEvent):void
			{
				// end the catch game
				
				endGame();
			}
			function playerHitBall(e:Event):void
			{
				// set properties that we will use to move the ball
				// generate a random speed
				//speed = Math.random() * 5 + 10;
				speed = 85;
				xI = _player.x + ballInitOffsetX;
				yI = _player.y + ballInitOffsetY;
				zI = 30;
				
				// create an instance of the baseball movieclip
				// have it start where the NPC would be hitting the ball
				// make it move across the screen and appear to go over the fence
				ball = new _ballClass();
				ball.x = xI;
				ball.y = yI;
				ballZ = zI;
				_background.addChild(ball);
				
				// create a ball shadow instance
				// make it follow the ball
				shadow = new _ballShadowClass();
				shadow.x = ball.x;
				shadow.y = ball.y;
				shadow.y += ballZ;
				// set shadow opacity
				shadow.alpha = 0.3;
				_background.addChildAt(shadow, _background.getChildIndex(ball));
				
				// determine random angle for trajectory of the ball
				// from the top down perspective
				// somewhere between -3/16*PI and -11/16*PI radians
				fieldAngle = Math.random() * (-8 / 16 * Math.PI) - (3 / 16 * Math.PI);
				
				// determine random angle for trajectory of the ball
				// from the perspective of right field looking at left
				// somewhere between -13/32*PI and -14/32*PI radians
				rightToLeftAngle = Math.random() * (-1 / 32 * Math.PI) - (13 / 32 * Math.PI);
				
				// from our right to left perspective angle of trajectory
				// determine a simulation velocity x & y
				v0X = Math.cos(rightToLeftAngle) * speed;
				v0Y = Math.sin(rightToLeftAngle) * speed;
				
				// increment hits on the catch game board
				_hud.Hits++;
				
				if (_hud.Hits >= hitLimit) hitLimitReached = true;
				
				// set boolean switch
				// true if the ball has hit the ground since it has been hit
				ballHitGround = false;
				
				// play a hit sound
				_channel = _hitSound.play();
				
				// start the timer
				tmr.start();
			}
			
			function endGame():void
			{
				// remove listeners
				_roomContainer.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				//removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
				_player.removeEventListener(_player.HIT_INSTANCE, playerHitBall);
				tmr.removeEventListener(TimerEvent.TIMER, timer);
				tmr2.removeEventListener(TimerEvent.TIMER, timer2);
				_roomContainer.removeEventListener(MouseEvent.CLICK, gloveSecondClick);
				
				// if there is currently a ball in play
				// remove it
				if (ball && _background.contains(ball)) _background.removeChild(ball);
				
				// if there is a caught ball
				// remove the caught ball
				if (caughtBall && _glove.contains(caughtBall)) _glove.removeChild(caughtBall);
				
				// if there is a ball shadow
				// remove it
				if (shadow && _background.contains(shadow)) _background.removeChild(shadow);
				
				// scale down baseball glove
				_glove.scaleX = _glove.scaleY = 0.6;
				// place the glove back at it's initial position
				_glove.x = gloveInitX;
				_glove.y = gloveInitY;
				
				// send the NPC animation to it's first frame
				_player.gotoAndStop(1);
				
				// create a timer that will be used to hide the catch game board
				gBTmr = new Timer(10);
				gBTmr.addEventListener(TimerEvent.TIMER, gBTmrInt);
				gBTmr.start();
				
				// set status of the game board
				var catches:int = _hud.Catches;
				var hits:int = _hud.Hits;
				var prcnt:Number = (hits > 0) ? Math.floor(catches / hits * 100) : 0;
				
				// determine result text based on catches
				var resultText:String;
				if (prcnt == 0)
				{
					resultText = 'You did not catch any fly balls.\n<font color="#ffffff">Click on Zoey</font> to try again!';
				}
				else if (prcnt <= 50)
				{
					resultText = 'You caught <font color="#ffffff">' + catches + '</font> out of <font color="#ffffff">' + hits + '</font> fly balls.\n<font color="#ffffff">Click on Zoey</font> to try again!';
				}
				else if (prcnt < 100)
				{
					resultText = 'Great job! You caught <font color="#ffffff">' + catches + '</font> out of <font color="#ffffff">' + hits + '</font> fly balls.\n<font color="#ffffff">Click on Zoey</font> to play again!';
				}
				else
				{
					resultText = 'Great job! You caught every fly ball!\n<font color="#ffffff">Click on Zoey</font> to play again!';
				}
				// set the result text
				_hud.Status = resultText;
				
				// play some animations on the game board
				//_hud.Title.gotoAndPlay('sequence');
				_hud.Fireworks.gotoAndPlay('sequence');
				
				// add mouse over and out listeners to the player/batter
				_player.addEventListener(MouseEvent.ROLL_OVER, playerRollOver);
				_player.addEventListener(MouseEvent.ROLL_OUT, playerRollOut);
				
				// show the mouse
				_roomContainer.hideCustomCursor = false;
				
				// play a crowd cheer sound
				_channel = _crowdCheerSound.play();
			}
			
			function gBTmrInt(e:TimerEvent):void
				{
					var cnt:int = gBTmr.currentCount;
					if (cnt > 450)
					{
						_hud.alpha -= 0.05;
					}
					
					if (cnt > 470)
					{
						// remove this timer listener
						gBTmr.removeEventListener(TimerEvent.TIMER, gBTmrInt);
						gBTmr.reset();
						
						// hide the catch game board
						_hud.visible = false;
						
						// reset some animations on the game board
						_hud.Fireworks.gotoAndPlay('idle');
						
						// set boolean switch
						// true if catch game is taking place
						catchGameIsOn = false;
						
						// add mouse interaction listeners to the player
						_player.addEventListener(MouseEvent.CLICK, playerFirstClick);
					}
				}
			
			// timer interval event handler
			function timer(e:TimerEvent):void
			{
				// using general trajectory equation
				// get position of an object in 2D space
				var i:int = tmr.currentCount;
				var simPosition:Point = GeneralTrajectory.GetPosition(aX, aY, v0X, v0Y, i, 5);
				
				// check the height of the ball
				// check for catches
				// check for collisions with the ground
				var nextZ:Number = zI - simPosition.y;
				if (nextZ <= 0)
				{
					// if ball z will be at or below 0 on this cycle
					
					// check if it is touching the glove
					// consider it caught if so
					
					// create rectangles to represent the area of the ball and the glove
					var nextBallX:Number = xI + Math.cos(fieldAngle) * simPosition.x;
					var nextBallY:Number = yI + Math.sin(fieldAngle) * simPosition.x - ballZ;
					var ballArea:Rectangle = new Rectangle(ball.x - ball.width / 2, ball.y - ball.height, ball.width, ball.height);
					var gloveArea:Rectangle = new Rectangle(_glove.x - 11, _glove.y - 10, 22, 20);
					if (ballArea.intersects(gloveArea))
					{
						// ball is caught
						// reset timer
						tmr.reset();
						
						// play a catch sound
						_channel = _catchSound.play();
						
						// get the offset of the glove to the ball
						var gBOffSetX:Number = ball.x - _glove.x;
						var gBOffSetY:Number = ball.y - _glove.y;
						
						// make the ball now follow the glove
						// add the ball to the display list of the glove
						caughtBall = ball;
						ball = null;
						_glove.addChild(caughtBall);
						// center the ball within the glove
						caughtBall.x = 0;
						caughtBall.y = 0;
						//caughtBall.x = gBOffSetX;
						//caughtBall.y = gBOffSetY;
						
						// close the glove
						_glove.gotoAndStop('catch');
						
						// remove the ball shadow
						_background.removeChild(shadow);
						shadow = null;
						
						// if the ball hasnt hit the ground
						// since it was hit
						// increment catches on the catch game board
						if (!ballHitGround) _hud.Catches++;
						
						// listen for intervals on a timer
						// will remove a caught ball
						tmr2.addEventListener(TimerEvent.TIMER, timer2);
						
						// start the timer that will remove a caught ball
						// after a period of time
						tmr2.start();
						
						// terminate the function
						return;
					}
					
					// if the ball was NOT caught
					// simulate it bouncing off the ground
					ballZ = zI = 0;
					ball.x = xI = xI + Math.cos(fieldAngle) * simPosition.x;
					ball.y = yI = yI + Math.sin(fieldAngle) * simPosition.x;
					speed *= 0.3;
					// recalculate velocity
					v0X = Math.cos(rightToLeftAngle) * speed;
					v0Y = Math.sin(rightToLeftAngle) * speed;
					
					// set boolean switch
					// true if the ball has hit the ground since it has been hit
					ballHitGround = true;
					
					// if the ball screen Y coordinate is further than what the glove can reach
					// start the timer that will eventualy remove the ball
					if (ball.y < gloveMinY)
					{
						// listen for intervals on a timer
						// will remove the ball
						tmr2.addEventListener(TimerEvent.TIMER, timer2);
						
						// start the timer that will remove the ball
						// after a period of time
						tmr2.start();
					}
					
					tmr.reset();
					tmr.start();
				}
				else
				{
					// position the ball
					// translate a point in 2D space to screen coordinates
					// based on our custom projection onto the field
					ballZ = nextZ;
					ball.x = xI + Math.cos(fieldAngle) * simPosition.x;
					ball.y = yI + Math.sin(fieldAngle) * simPosition.x - ballZ;
				}
				
				
				
				// make the ball shadow follow the ball
				shadow.x = ball.x;
				shadow.y = ball.y + ballZ;
				
				// scale shadow according to height
				shadow.scaleX = shadow.scaleY = ballZ / 200 + 1;
			}
			
			function timer2(e:TimerEvent):void
			{
				// remove the listener for this timer
				// because we only want the handler to be called once
				tmr2.removeEventListener(TimerEvent.TIMER, timer2);
				tmr2.stop();
				
				// reset timer 1
				tmr.reset();
				
				// remove the caught ball
				if (caughtBall && _glove.contains(caughtBall))
				{
					_glove.removeChild(caughtBall);
				}
				else if (_background.contains(ball))
				{
					_background.removeChild(ball);
				}
				
				// remove the ball shadow
				if (shadow && _background.contains(shadow))
				{
					_background.removeChild(shadow);
					shadow = null;
				}
				
				// open the glove
				_glove.gotoAndStop('idle');
				
				if (hitLimitReached != true)
				{
					// play the npc animation of the player hitting the ball
					_player.gotoAndPlay("swingBat");
				}
				else
				{
					// end the catch game and show my score
					endGame();
				}
			}
		}
		
	}
}
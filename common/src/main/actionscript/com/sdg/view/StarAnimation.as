package com.sdg.view
{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class StarAnimation extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		
		public function StarAnimation(width:Number, height:Number)
		{
			super();
			
			_width = width;
			_height = height;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function animate(directionVector:Point, count:uint, meanSpeed:Number, size:Number, distanceX:Number):void
		{
			// Randomly generate a bunch of stars and animate them.
			var i:uint = 0;
			var len:uint = count;
			var angle:Number = Math.atan2(directionVector.y, directionVector.x);
			var rightAngle:Number = angle + Math.PI / 2;
			var speedRange:Number = 10;
			for (i; i < len; i++)
			{
				var star:Sprite = new StarGraphic(size, size, 0xffffff);
				star.blendMode = BlendMode.ADD;
				star.cacheAsBitmap = true;
				var disFromCenter:Number = Math.random() * _height - _height / 2;
				var delayDis:Number = -Math.random() * distanceX;
				var xI:Number = Math.cos(rightAngle) * disFromCenter;
				var yI:Number = Math.sin(rightAngle) * disFromCenter;
				var alphaI:Number = Math.random();
				var speed:Number = Math.random() * speedRange + meanSpeed - (speedRange / 2);
				var xV:Number = Math.cos(angle) * speed;
				var yV:Number = Math.sin(angle) * speed;
				var rotationSpeed:Number = Math.random() * meanSpeed / 2;
				
				star.x = xI + Math.cos(angle) * delayDis;
				star.y = yI + Math.sin(angle) * delayDis;
				star.alpha = alphaI;
				
				animateStar(star, xV, yV, xI, angle, rotationSpeed);
			}
			
			function animateStar(star:Sprite, xV:Number, yV:Number, xI:Number, angle:Number, rotationSpeed:Number):void
			{
				var speed:Number = Math.sqrt(Math.pow(xV, 2) + Math.pow(yV, 2));
				var added:Boolean = false;
				
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				
				function onEnterFrame(e:Event):void
				{
					star.x = star.x + xV;
					star.y = star.y + yV;
					star.rotation += rotationSpeed;
					var distance:Number = (star.x - xI) / Math.cos(angle);
					if (distance > distanceX)
					{
						removeEventListener(Event.ENTER_FRAME, onEnterFrame);
						if (added == true) removeChild(star);
					}
					else if (distance > 0)
					{
						if (added == false)
						{
							addChild(star);
							added = true;
						}
						star.alpha -= (1 / (distanceX / speed));
					}
				}
			}
		}
		
		private function createStar(width:Number, height:Number, color:uint):Sprite
		{
			var star:Sprite = new Sprite();
			star.graphics.beginFill(color);
			star.graphics.drawCircle(0, 0, width / 2);
			return star;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			_width = value;
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			_height = value;
		}
		
	}
}
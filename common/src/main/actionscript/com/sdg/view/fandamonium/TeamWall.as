package com.sdg.view.fandamonium
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class TeamWall extends Sprite
	{
		public const TOP_LEFT:int = 0;
		public const TOP_RIGHT:int = 1;
		public const BOTTOM_LEFT:int = 2;
		public const BOTTOM_RIGHT:int = 3;
		
		private var _logo:DisplayObject;
		private var _color:uint = 0xffffff;
		private var _wallPoints:Array;
		private var _logoSize:int = 0;
		private var _logoPosition:Point;
		private var _gradientRotation:Number = 0;
		private var _logoSkewFactor:Number = 0;
		private var _logoContainer:Sprite = new Sprite();
		
		public function TeamWall(topLeft:Point, topRight:Point, bottomLeft:Point, bottomRight:Point, gradientRotation:Number = 0)
		{
			super();
			addChild(_logoContainer);
			_wallPoints = [topLeft, topRight, bottomLeft, bottomRight];
			_logoPosition = topLeft;
			
			_gradientRotation = gradientRotation;
		}
		
		private function draw():void
		{
			graphics.clear();
			if (_color)
			{
				var topLeft:Point = _wallPoints[TOP_LEFT];
				var topRight:Point = _wallPoints[TOP_RIGHT];
				var bottomLeft:Point = _wallPoints[BOTTOM_LEFT];
				var bottomRight:Point = _wallPoints[BOTTOM_RIGHT];
				
				var minX:Number = Math.min(topLeft.x, bottomLeft.x);
				var maxX:Number = Math.max(topRight.x, bottomRight.x);
				var minY:Number = Math.min(topLeft.y, topRight.y);
				var maxY:Number = Math.max(bottomLeft.y, bottomRight.y);
				
				var w:Number = maxX - minX;
				var h:Number = maxY - minY;
				
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(w, h*1.3, _gradientRotation, minX, minY);
				graphics.beginGradientFill(GradientType.LINEAR, [_color, 0x000000], [1, 1], [0, 255], gradientBoxMatrix);
				//graphics.beginFill(_color);
				
				graphics.moveTo(topLeft.x, topLeft.y);
				graphics.lineTo(topRight.x, topRight.y);
				graphics.lineTo(bottomRight.x, bottomRight.y);
				graphics.lineTo(bottomLeft.x, bottomLeft.y);
				graphics.lineTo(topLeft.x, topLeft.y);
				
				graphics.endFill();
			}
		}
		
		private function positionLogo():void
		{
			if (_logo)
			{
				// Position the new logo.
				_logoContainer.x = _logoPosition.x - _logoContainer.width/2;
				_logoContainer.y = _logoPosition.y - _logoContainer.height/2;
			}
		}
		
		private function transformLogo():void
		{
			if (_logo && _logoSize > 0)
			{
				_logoContainer.scaleX = 1;
				_logoContainer.scaleY = 1;
				
				// Skew the logo.
				var skewMatrix:Matrix = new Matrix();
				skewMatrix.b = Math.tan(_logoSkewFactor);
				_logoContainer.transform.matrix = skewMatrix;
				
				// Size the new logo.
				var logoScale:Number = Math.min(_logoSize / _logoContainer.width, _logoSize / _logoContainer.height);
				_logoContainer.scaleX = _logoContainer.scaleY = logoScale;
			}
		}
		
		public function setWallPoints(topLeft:Point, topRight:Point, bottomLeft:Point, bottomRight:Point):void
		{
			if (topLeft) _wallPoints[TOP_LEFT] = topLeft;
			if (topRight) _wallPoints[TOP_RIGHT] = topRight;
			if (bottomLeft) _wallPoints[BOTTOM_LEFT] = bottomLeft;
			if (bottomRight) _wallPoints[BOTTOM_RIGHT] = bottomRight;
			
			draw();
		}
				
		public function set gradientRotation(value:Number):void
		{
			if (value == _gradientRotation)
				return;
			
			_gradientRotation = value;
			draw();
		}
		
		public function set logoSkewFactor(value:Number):void
		{
			if (value == _logoSkewFactor)
				return;
			
			_logoSkewFactor = value;
			transformLogo();
		}
		
		public function set logo(value:DisplayObject):void
		{
			if (_logo)
			{
				if (value == _logo)
					return;
				else
					_logoContainer.removeChild(_logo);
			}
			_logo = value;
			_logoContainer.addChild(_logo);
			_logoContainer.filters = [new GlowFilter(0xffffff, 1, 3, 3, 10)];
			
			transformLogo();
			positionLogo();
		}
		
		public function set logoSize(value:int):void
		{
			if (value == _logoSize)
				return;
				
			_logoSize = value;
			transformLogo();
		}
		
		public function set logoPosition(value:Point):void
		{
			if (value == _logoPosition)
				return;
				
			_logoPosition = value;
			positionLogo();
		}
		
		public function set color(value:uint):void
		{
			if (value == _color)
				return;
			
			_color = value;
			draw();
		}
	}
}

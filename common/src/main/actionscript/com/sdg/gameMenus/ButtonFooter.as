package com.sdg.gameMenus
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class ButtonFooter extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _button:DisplayObject;
		
		protected const valleyHalfWidth:int = 150;
		protected const valleyHeight:int = 70;
		protected const valleyCurveXDiff:int = 20;
		protected const cornerRadius:int = 15;
		protected const curveAdjust:int = 3;
		protected const startY:int = 10;
		
		public function ButtonFooter(width:Number = 925, height:Number = 90)
		{
			super();
			_width = width;
			_height = height;
			
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, _width, _height);
			
			var leftOutX:Number = _width/2 - valleyHalfWidth;
			var rightOutX:Number = _width/2 + valleyHalfWidth;
			var leftInX:Number = leftOutX + valleyCurveXDiff;
			var rightInX:Number = rightOutX - valleyCurveXDiff;
			
			var blueSprite:Sprite = new Sprite();
			blueSprite.graphics.beginFill(0x182C4E);
			blueSprite.graphics.moveTo(0, startY);
			blueSprite.graphics.lineTo(leftOutX - cornerRadius, startY);
			blueSprite.graphics.curveTo(leftOutX, startY, leftOutX + curveAdjust, startY + cornerRadius - curveAdjust);
			blueSprite.graphics.lineTo(leftInX - curveAdjust, startY + valleyHeight - cornerRadius + curveAdjust);
			blueSprite.graphics.curveTo(leftInX, startY + valleyHeight, leftInX + cornerRadius, startY + valleyHeight);
			blueSprite.graphics.lineTo(rightInX - cornerRadius, startY + valleyHeight);
			blueSprite.graphics.curveTo(rightInX, startY + valleyHeight, rightInX + curveAdjust, startY + valleyHeight - cornerRadius + curveAdjust);
			blueSprite.graphics.lineTo(rightOutX - curveAdjust, startY + cornerRadius - curveAdjust);
			blueSprite.graphics.curveTo(rightOutX, startY, rightOutX + cornerRadius, startY);
			blueSprite.graphics.lineTo(_width, startY);
			blueSprite.graphics.lineTo(_width, _height);
			blueSprite.graphics.lineTo(0, _height);		
			
			addChild(blueSprite);
		}
		
		public function set button(value:DisplayObject):void
		{
			if (_button == value) return;
			
			if (_button != null) removeChild(_button);
			
			_button = value;
			_button.x = _width/2 - _button.width/2;
			_button.y = startY;
			addChild(_button);
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
	}
}
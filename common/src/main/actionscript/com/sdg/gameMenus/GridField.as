package com.sdg.gameMenus
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class GridField extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _display:DisplayObject;
		protected var _centerAligned:Boolean;
		protected var _leftMargin:int;
		
		public function GridField(width:Number, height:Number, display:DisplayObject, centerAligned:Boolean = true, leftMargin:int = 0)
		{
			super();
			_width = width;
			_height = height;
			_centerAligned = centerAligned;
			_leftMargin = leftMargin;
			
			_display = display;
			addChild(_display);
			render();
		}
		
		protected function render():void
		{
			graphics.clear();
			
			graphics.lineStyle(1, 0x718799);
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, _width, _height);
			
			var startX:Number = 0;
			
			if (_display.parent != this)
				startX = x;
			
			if (_centerAligned)
				_display.x = startX + _width/2 - _display.width/2;
			else
				_display.x = startX + _leftMargin;
			
			_display.y = _height/2 - _display.height/2;
		}
		
		public function get display():DisplayObject
		{
			return _display;
		}
		
		public function set fieldHeight(value:Number):void
		{
			_height = value;
			
			render();
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
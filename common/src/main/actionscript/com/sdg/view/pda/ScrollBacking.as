package com.sdg.view.pda
{
	import flash.display.Sprite;

	public class ScrollBacking extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		
		public function ScrollBacking()
		{
			super();
			
			// Set default values.
			_width = 18;
			_height = 18;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		protected function render():void
		{
			graphics.clear();
			graphics.beginFill(0x003366);
			graphics.lineStyle(2, 0x003366);
			graphics.drawRoundRect(0, 0, _width, _height, 5, 5);
			graphics.endFill();
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
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
	}
}
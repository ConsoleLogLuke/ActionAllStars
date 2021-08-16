package com.good.goodui
{
	import flash.display.Sprite;

	public class FluidView extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		
		public function FluidView(width:Number, height:Number)
		{
			super();
			
			_width = width;
			_height = height;
		}
		
		protected function render():void
		{
			
		}
		
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
package com.sdg.view
{
	import flash.display.Sprite;

	public class StarGraphic extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _color:uint;
		
		public function StarGraphic(width:Number, height:Number, color:uint = 0xffffff)
		{
			super();
			_width = width;
			_height = height;
			_color = color;
			
			render();
		}
		
		private function render():void
		{
			graphics.beginFill(_color);
			moveTo(.5, 0);
			lineTo(.6, .35);
			lineTo(1, .35);
			lineTo(.72, .6);
			lineTo(.85, 1);
			lineTo(.5, .75);
			lineTo(.15, 1);
			lineTo(.28, .6);
			lineTo(0, .35);
			lineTo(.4, .35);
			lineTo(.5, 0);
			
			function moveTo(x:Number, y:Number):void
			{
				graphics.moveTo(x * _width, y * _height);
			}
			
			function lineTo(x:Number, y:Number):void
			{
				graphics.lineTo(x * _width, y * _height);
			}
		}
		
		public function set color(value:uint):void
		{
			if (value == _color) return;
			
			_color = value;
			render();
		}
	}
}
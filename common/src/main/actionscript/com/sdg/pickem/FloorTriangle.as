package com.sdg.pickem
{
	import com.sdg.display.AlignType;
	
	import flash.display.Sprite;

	public class FloorTriangle extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _color:uint;
		private var _align:String;
		
		public function FloorTriangle(width:Number = 100, height:Number = 100, color:uint = 0x0000ff, align:String = null)
		{
			super();
			
			_width = width;
			_height = height;
			_color = color;
			_align = (align != null && align != '') ? align : AlignType.LEFT;
			
			render();
		}
		
		public function render():void
		{
			graphics.clear();
			graphics.beginFill(_color);
			
			if (_align == AlignType.LEFT)
			{
				graphics.moveTo(_width, 0);
				graphics.lineTo(_width, _height);
				graphics.lineTo(0, _height / 2);
				graphics.lineTo(_width, 0);
			}
			else if (_align == AlignType.RIGHT)
			{
				graphics.moveTo(0, 0);
				graphics.lineTo(_width, _height / 2);
				graphics.lineTo(0, _height);
				graphics.lineTo(0, 0);
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
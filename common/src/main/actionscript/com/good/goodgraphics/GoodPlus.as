package com.good.goodgraphics
{
	import com.good.goodui.FluidView;

	public class GoodPlus extends FluidView
	{
		protected var _color:uint;
		protected var _thickness:Number;
		
		public function GoodPlus(width:Number, height:Number, color:uint = 0xffffff, thickness:Number = 0.3333)
		{
			super(width, height);
			
			_color = color;
			_thickness = thickness;
			
			render();
		}
		
		override protected function render():void
		{
			var rectWidth:Number = _width * _thickness;
			var rectHeight:Number = _height * _thickness;
			var offX:Number = (_width - rectWidth) / 2;
			var offY:Number = (_height - rectHeight) / 2;
			
			graphics.clear();
			graphics.beginFill(_color);
			graphics.drawRect(0, offY, _width, rectHeight);
			graphics.endFill();
			graphics.beginFill(_color);
			graphics.drawRect(offX, 0, rectWidth, _height);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get color():uint
		{
			return _color;
		}
		public function set color(value:uint):void
		{
			if (value == _color) return;
			_color = value;
			render();
		}
		
		public function get thickness():Number
		{
			return _thickness;
		}
		public function set thickness(value:Number):void
		{
			if (value == _thickness) return;
			_thickness = value;
			render();
		}
		
	}
}
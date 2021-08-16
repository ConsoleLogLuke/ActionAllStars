package com.good.goodgraphics
{
	import com.good.goodui.FluidView;

	public class GoodMinus extends FluidView
	{
		protected var _color:uint;
		protected var _thickness:Number;
		
		public function GoodMinus(width:Number, height:Number, color:uint = 0xffffff, thickness:Number = 0.3333)
		{
			super(width, height);
			
			_color = color;
			_thickness = thickness;
			
			render();
		}
		
		override protected function render():void
		{
			var rectHeight:Number = _height * _thickness;
			var offY:Number = (_height - rectHeight) / 2;
			
			graphics.clear();
			graphics.beginFill(_color);
			graphics.drawRect(0, offY, _width, rectHeight);
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
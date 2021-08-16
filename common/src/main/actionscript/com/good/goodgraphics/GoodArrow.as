package com.good.goodgraphics
{
	import com.good.goodui.FluidView;

	public class GoodArrow extends FluidView
	{
		protected var _color:uint;
		
		public function GoodArrow(width:Number, height:Number, color:uint = 0xffffff)
		{
			super(width, height);
			
			_color = color;
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			graphics.clear()
			graphics.beginFill(_color);
			graphics.moveTo(-_width / 2, -_height / 2);
			graphics.lineTo(_width / 2, 0);
			graphics.lineTo(-_width / 2, _height / 2);
		}
		
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
		
	}
}
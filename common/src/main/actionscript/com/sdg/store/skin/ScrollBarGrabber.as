package com.sdg.store.skin
{
	import com.good.goodui.FluidView;

	public class ScrollBarGrabber extends FluidView
	{
		private var _color:uint;
		
		public function ScrollBarGrabber(color:uint = 0xffffff)
		{
			_color = color;
			
			super(10, 10);
			
			render();
		}
		
		override protected function render():void
		{
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			graphics.beginFill(_color);
			var off:Number = _width * 0.2;
			var hW:Number = _width / 2;
			graphics.drawRoundRect(off, 0, _width - off * 2, _height, hW, hW);
		}
		
	}
}
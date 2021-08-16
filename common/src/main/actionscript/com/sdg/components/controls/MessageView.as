package com.sdg.components.controls
{
	import mx.containers.Canvas;
	
	public class MessageView extends Canvas
	{
		private static const CORNER_RADIUS:Number = 15;
		
		private var _leftIndent:Number = 10;
		private var _rightIndent:Number = 2;
		private var _topIndent:Number = 4;
		private var _bottomIndent:Number = 4;
		
		public function MessageView()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			graphics.clear();
			graphics.lineStyle(2, 0x000000, 1, true);
			graphics.beginFill(0x80002A, .8);
			graphics.drawRoundRect(_leftIndent, _topIndent, w - _leftIndent - _rightIndent, h - _topIndent - _bottomIndent, CORNER_RADIUS, CORNER_RADIUS);
			graphics.endFill();
		}
		
		public function set leftIndent(value:Number):void
		{
			_leftIndent = value;
		}
		
		public function set rightIndent(value:Number):void
		{
			_rightIndent = value;
		}
		
		public function set topIndent(value:Number):void
		{
			_topIndent = value;
		}
		
		public function set bottomIndent(value:Number):void
		{
			_bottomIndent = value;
		}
	}
}
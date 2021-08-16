package com.sdg.shape
{
	import flash.display.Graphics;

	public class PointLeftBox extends Shape
	{
		private var _pointSize:Number;
		
		public function PointLeftBox(x:Number, y:Number, width:Number, height:Number, pointSize:Number)
		{
			super(x, y, width, height);
			
			_pointSize = pointSize;
		}
		
		override public function draw(graphicsObject:Graphics):void
		{
			graphicsObject.moveTo(_x + _pointSize, _y);
			graphicsObject.lineTo(_x + _width, _y);
			graphicsObject.lineTo(_x + _width, _y + _height);
			graphicsObject.lineTo(_x + _pointSize, _y + _height);
			graphicsObject.lineTo(_x, _y + (_height / 2));
			graphicsObject.lineTo(_x + _pointSize, _y);
		}
		
	}
}
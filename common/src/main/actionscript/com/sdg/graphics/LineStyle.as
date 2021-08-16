package com.sdg.graphics
{
	public class LineStyle extends Object
	{
		public var Thickness:Number;
		public var Color:uint;
		public var Alpha:Number;
		public var PixelHint:Boolean;
		
		public function LineStyle(thickness:Number = 0, color:uint = 0x000000, alpha:Number = 1, pixelHint:Boolean = true)
		{
			Thickness = thickness;
			Color = color;
			Alpha = alpha;
			PixelHint = pixelHint;
		}
	}
}
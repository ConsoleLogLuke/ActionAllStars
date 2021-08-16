package com.sdg.graphics.customShapes
{
	import com.sdg.graphics.customShapes.interfaces.ICustomShape;
	
	import flash.display.Graphics;
	
	[Bindable]
	public class RoundRectComplex implements ICustomShape
	{
		public var width:Number;
		public var height:Number;
		public var topLeftRadius:Number;
		public var topRightRadius:Number;
		public var bottomLeftRadius:Number;
		public var bottomRightRadius:Number;
		
		public function RoundRectComplex(width:Number = 0, height:Number = 0,
										topLeftRadius:Number = 0, topRightRadius:Number = 0,
										bottomLeftRadius:Number = 0, bottomRightRadius:Number = 0)
		{
			this.width = width;
			this.height = height;
			this.topLeftRadius = topLeftRadius;
			this.topRightRadius = topRightRadius;
			this.bottomLeftRadius = bottomLeftRadius;
			this.bottomRightRadius = bottomRightRadius;
		}
		
		public function draw(g:Graphics, x:Number = 0, y:Number = 0):void
		{
			g.drawRoundRectComplex(x, y, width, height, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius);
		}
	}
}
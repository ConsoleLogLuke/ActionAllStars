package com.sdg.graphics.customShapes
{
	import com.sdg.graphics.customShapes.interfaces.ICustomShape;
	
	import flash.display.Graphics;
	
	[Bindable]
	public class RoundRect implements ICustomShape
	{
		public var width:Number;
		public var height:Number;
		public var cornerRadius:Number;
		
		public function RoundRect(width:Number = 0, height:Number = 0, cornerRadius:Number = 0)
		{
			this.width = width;
			this.height = height;
			this.cornerRadius = cornerRadius;
		}
		
		public function draw(g:Graphics, x:Number = 0, y:Number = 0):void
		{
			g.drawRoundRect(x, y, width, height, cornerRadius*2, cornerRadius*2);
		}
	}
}
package com.sdg.graphics.customShapes
{
	import flash.display.Graphics;

	public class SlantedStarShape
	{
		public var width:Number;
		public var height:Number;
		
		public function SlantedStarShape(widthIn:Number = 0, heightIn:Number = 0)
		{
			this.width = widthIn;
			this.height = heightIn;
		}
		
		public function draw(g:Graphics):void
		{
			g.moveTo(7/13*width,0);
			g.lineTo(8/13*width,.4*height);
			g.lineTo(width,.4*height);
			g.lineTo(8.3/13*width,.6*height);
			g.lineTo(8.6/13*width,height);
			g.lineTo(5/13*width,.8*height);
			g.lineTo(0,height);			
			g.lineTo(3/13*width,.6*height);
			g.lineTo(0,.4*height);			
			g.lineTo(4.7/13*width,.4*height);
			g.lineTo(7/13*width,0);	
		}
		
		public function drawLeftHalf(g:Graphics):void
		{
			g.moveTo(7/13*width,0);
			g.lineTo(5/13*width,.8*height);
			g.lineTo(0,height);			
			g.lineTo(3/13*width,.6*height);
			g.lineTo(0,.4*height);			
			g.lineTo(4.7/13*width,.4*height);
			g.lineTo(7/13*width,0);	
		}
		
		public function drawRightHalf(g:Graphics):void
		{
			g.moveTo(7/13*width,0);
			g.lineTo(8/13*width,.4*height);
			g.lineTo(width,.4*height);
			g.lineTo(8.3/13*width,.6*height);
			g.lineTo(8.6/13*width,height);
			g.lineTo(5/13*width,.8*height);
			g.lineTo(7/13*width,0);	
		}
		
		public function drawTestBox(g:Graphics):void
		{
			g.moveTo(0+width*.1,0+height*.1);
			g.lineTo(width*.9,0+height*.1);
			g.lineTo(width*.9,height*.9);
			g.lineTo(0+width*.1,height*.9);
			g.lineTo(0+width*.1,0+height*.1);
		}
		
	}
}
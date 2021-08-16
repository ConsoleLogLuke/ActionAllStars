package com.sdg.graphics.customShapes
{
	import com.sdg.graphics.customShapes.interfaces.ICustomShape;
	
	import flash.display.Graphics;
	
	[Bindable]
	public class BevelShape implements ICustomShape
	{
		public var width:Number;
		public var height:Number;
		public var topCornerRadius:Number;
		public var bottomCornerRadius:Number;
		public var topBevelHeight:Number;
		public var bottomBevelHeight:Number;
		public var topBevelXStart:Number;
		public var bottomBevelXStart:Number;
		public var topBevelControlYAdjustment:Number;
		public var bottomBevelControlYAdjustment:Number;
		
		public function BevelShape(width:Number = 0, height:Number = 0,
									topCornerRadius:Number = 0, bottomCornerRadius:Number = 0,
									topBevelHeight:Number = 0, bottomBevelHeight:Number = 0,
									topBevelXStart:Number = 0, bottomBevelXStart:Number = 0,
									topBevelControlYAdjustment:Number = 0, bottomBevelControlYAdjustment:Number = 0)
		{
			this.width = width;
			this.height = height;
			this.topCornerRadius = topCornerRadius;
			this.bottomCornerRadius = bottomCornerRadius;
			this.topBevelHeight = topBevelHeight;
			this.bottomBevelHeight = bottomBevelHeight;
			this.topBevelXStart = topBevelXStart;
			this.bottomBevelXStart = bottomBevelXStart;
			this.topBevelControlYAdjustment = topBevelControlYAdjustment;
			this.bottomBevelControlYAdjustment = bottomBevelControlYAdjustment;
		}
		
		public function draw(g:Graphics, x:Number = 0, y:Number = 0):void
		{
			g.moveTo(topBevelXStart + x, topBevelHeight + y);
			g.curveTo(width / 2 + x, -topBevelHeight + y, width - topBevelXStart + x, topBevelHeight + y);
			g.curveTo(width + x, topBevelHeight + topBevelControlYAdjustment + y, width + x, topBevelHeight + topCornerRadius + y);
			g.lineTo(width + x, height - bottomBevelHeight - bottomCornerRadius + y);
			g.curveTo(width + x, height - bottomBevelHeight - bottomBevelControlYAdjustment + y, width - bottomBevelXStart + x, height - bottomBevelHeight + y);
			g.curveTo(width / 2 + x, height + bottomBevelHeight + y, bottomBevelXStart + x, height - bottomBevelHeight + y);
			g.curveTo(0 + x, height - bottomBevelHeight - bottomBevelControlYAdjustment + y, 0 + x, height - bottomBevelHeight - bottomCornerRadius + y);
			g.lineTo(0 + x, topBevelHeight + topCornerRadius + y);
			g.curveTo(0 + x, topBevelHeight + topBevelControlYAdjustment + y, topBevelXStart + x, topBevelHeight + y);
		}
	}
}
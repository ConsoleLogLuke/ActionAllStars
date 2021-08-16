package com.sdg.graphics
{
	import flash.display.Sprite;

	public class SolidFill extends Sprite implements IFill
	{
		protected var CWidth:Number = -1;
		protected var CHeight:Number = -1;
		protected var CColor:uint = 0xFFFFFF;

		public function SolidFill(color:uint = 0x000000, width:Number = 100, height:Number = 100)
		{
			Width = width;
			Height = height;
			Color = color;
		}
		
		public function Draw():void
		{
			graphics.clear();
			graphics.beginFill(Color);
			graphics.drawRect(0,0,CWidth,CHeight);
			graphics.endFill();
		}
		public function GetDuplicate():IFill
		{
			// return a duplicate of this fill object
			var fill:SolidFill = new SolidFill(Color, Width, Height);
			fill.Color = Color;
			fill.Alpha = Alpha;
			return fill;
		}
		
		// WIDTH
		public function set Width(newValue:Number):void
		{
			CWidth = newValue;
			Draw();
		}
		public function get Width():Number
		{
			return CWidth;
		}
		// HEIGHT
		public function set Height(newValue:Number):void
		{
			CHeight = newValue;
			Draw();
		}
		public function get Height():Number
		{
			return CHeight;
		}
		// COLOR
		public function set Color(newValue:uint):void
		{
			CColor = newValue;
			Draw();
		}
		public function get Color():uint
		{
			return CColor;
		}
		// ALPHA
		public function set Alpha(value:Number):void {
			this.alpha = value;
		}
		public function get Alpha():Number { return this.alpha; }
	}
}

/*protected var CMyVar:Type;
public function set MyVar(newValue:Type):void
{
CMyVar = newValue;
}
public function get MyVar():Type
{
return CMyVar;
}*/
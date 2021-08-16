package com.sdg.messageBoard.views
{
	public class ColorButton extends MessageOptionButton
	{
		public static const colorMap:Array = [0xfff4b6, 0x87eba5, 0x87b3eb, 0xfdd7ff];
		
		public function ColorButton(colorId:int, width:Number, height:Number)
		{
			super(colorId);
			
			graphics.lineStyle(3, 0x000000, 1, true);
			graphics.beginFill(colorMap[colorId]);
			graphics.drawRoundRect(0, 0, width, height, width/2, height/2);
		}
	}
}
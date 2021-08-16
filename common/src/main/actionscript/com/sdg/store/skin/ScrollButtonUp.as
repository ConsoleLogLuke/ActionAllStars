package com.sdg.store.skin
{
	import flash.display.Sprite;

	public class ScrollButtonUp extends Sprite
	{
		public function ScrollButtonUp(color:uint = 0x000000)
		{
			super();
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 20, 20);
			graphics.endFill();
			
			graphics.beginFill(color);
			graphics.moveTo(10, 4);
			graphics.lineTo(18, 16);
			graphics.lineTo(2, 16);
		}
		
	}
}
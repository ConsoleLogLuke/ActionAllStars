package com.sdg.store.skin
{
	import flash.display.Sprite;

	public class ScrollButtonDown extends Sprite
	{
		public function ScrollButtonDown(color:uint = 0x000000)
		{
			super();
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 20, 20);
			graphics.endFill();
			
			graphics.beginFill(color);
			graphics.moveTo(2, 4);
			graphics.lineTo(18, 4);
			graphics.lineTo(10, 16);
		}
		
	}
}
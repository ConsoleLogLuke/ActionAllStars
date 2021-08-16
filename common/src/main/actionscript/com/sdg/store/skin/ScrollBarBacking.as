package com.sdg.store.skin
{
	import flash.display.Sprite;

	public class ScrollBarBacking extends Sprite
	{
		public function ScrollBarBacking(color:uint = 0x222222, alpha:Number = 1)
		{
			super();
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 20, 20);
			graphics.endFill();
			
			graphics.beginFill(color, alpha);
			graphics.drawRect(7, 0, 6, 20);
		}
		
	}
}
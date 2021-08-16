package com.sdg.messageBoard.views
{
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	
	public class StickerButton extends MessageOptionButton
	{
		public static const NUM_STICKERS:int = 10;
		
		public function StickerButton(stickerId:int, width:Number, height:Number)
		{
			super(stickerId);
			
			var sticker:DisplayObject = new QuickLoader("assets/swfs/turfBuilder/msgBoard/sticker" + stickerId + ".swf", onComplete);
			
			function onComplete():void
			{
				sticker = QuickLoader(sticker).content;
				var scale:Number = Math.min(width/sticker.width, height/sticker.height);
				sticker.scaleX = sticker.scaleY = scale;
				addChild(sticker);
			}
		} 
	}
}
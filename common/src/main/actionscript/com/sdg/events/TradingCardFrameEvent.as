package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Image;

	public class TradingCardFrameEvent extends CairngormEvent
	{
		public static const TRADING_CARD_FRAME:String = "tradingCardFrame";
		
		private var _avatarId:uint;
		private var _frameImage:Image;
		
		public function TradingCardFrameEvent(avatarId:int, frameImage:Image)
		{
			super(TRADING_CARD_FRAME);
			_avatarId = avatarId;
			_frameImage = frameImage;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get frameImage():Image
		{
			return _frameImage;
		}
	}
}
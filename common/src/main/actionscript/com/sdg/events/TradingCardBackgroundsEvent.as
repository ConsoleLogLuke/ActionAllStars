package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.collections.ArrayCollection;

	public class TradingCardBackgroundsEvent extends CairngormEvent
	{
		public static const TRADING_CARD_BACKGROUNDS:String = "tradingCardBackgrounds";
		
		private var _avatarId:uint;
		private var _backgrounds:ArrayCollection;
		
		public function TradingCardBackgroundsEvent(avatarId:int, backgrounds:ArrayCollection)
		{
			super(TRADING_CARD_BACKGROUNDS);
			_backgrounds = backgrounds;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get backgrounds():ArrayCollection
		{
			return _backgrounds;
		}
	}
}
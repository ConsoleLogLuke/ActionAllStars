package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class TradingCardSaveEvent extends CairngormEvent
	{
		public static const TRADING_CARD_SAVE:String = "tradingCardSave";
		
		private var _avatarId:uint;
		private var _backgroundId:uint;
		private var _items:Array;
		
		public function TradingCardSaveEvent(avatarId:uint, backgroundId:uint, items:Array)
		{
			super(TRADING_CARD_SAVE);
			
			_avatarId = avatarId;
			_backgroundId = backgroundId;
			_items = items;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}		
		
		public function get backgroundId():uint
		{
			return _backgroundId;
		}		
		
		public function get items():Array
		{
			return _items;
		}		
	}
}
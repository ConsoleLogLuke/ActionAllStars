package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class TradingCardDeleteEvent extends CairngormEvent
	{
		public static const TRADING_CARD_DELETE:String = "tradingCardDelete";
		
		private var _avatarId:uint;
		private var _tradingCardId:uint;
		
		public function TradingCardDeleteEvent(avatarId:uint, tradingCardId:uint)
		{
			super(TRADING_CARD_DELETE);
			_avatarId = avatarId;
			_tradingCardId = tradingCardId;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}		
		
		public function get tradingCardId():uint
		{
			return _tradingCardId;
		}			
	}
}
package com.sdg.events
{
	import flash.events.Event;
	
	public class ConfirmTradingCardDeleteEvent extends Event
	{
		public static const CONFIRM_TRADING_CARD_DELETE:String = "confirmTradingCardDelete";
		
		private var _tradingCardId:uint;
		
		public function ConfirmTradingCardDeleteEvent(tradingCardId:uint)
		{
			super(CONFIRM_TRADING_CARD_DELETE);
			_tradingCardId = tradingCardId;
		}
		
		public function get tradingCardId():uint
		{
			return _tradingCardId;
		}			
	}
}
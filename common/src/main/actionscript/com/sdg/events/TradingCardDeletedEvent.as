package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class TradingCardDeletedEvent extends CairngormEvent
	{
		public static const TRADING_CARD_DELETED:String = "tradingCardDeleted";
		
		public function TradingCardDeletedEvent()
		{
			super(TRADING_CARD_DELETED);
		}	
	}
}
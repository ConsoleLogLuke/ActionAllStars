package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class TradingCardPurchaseEvent extends CairngormEvent
	{
		public static const TRADING_CARD_PURCHASE:String = "tradingCardPurchaseEvent";
		public static const TRADING_CARD_PURCHASE_COMPLETED:String = "tradingCardPurchaseCompletedEvent";
		
		private var _avatarId:uint;
		private var _tradingCardDefinitionId:uint;
		private var _cost:uint;
		
		public function TradingCardPurchaseEvent(type:String, avatarId:uint=0, tradingCardDefinitionId:uint=0, cost:uint=0)
		{
			super(type);
			_avatarId = avatarId;
			_tradingCardDefinitionId = tradingCardDefinitionId;
			_cost = cost;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get tradingCardDefinitionId():uint
		{
			return _tradingCardDefinitionId;
		}
		public function get cost():uint
		{
			return _cost;
		}
	}
}
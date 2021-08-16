package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.TradingCardPurchaseEvent;
	
	import mx.rpc.IResponder;
		
	public class TradingCardPurchaseCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _cost:uint;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:TradingCardPurchaseEvent = event as TradingCardPurchaseEvent;
			new SdgServiceDelegate(this).purchaseTradingCardPack(ev.avatarId, ev.tradingCardDefinitionId);
			_cost = ev.cost;
		}
		
		public function result(data:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new TradingCardPurchaseEvent(TradingCardPurchaseEvent.TRADING_CARD_PURCHASE_COMPLETED, 0, 0, _cost));
		}
	}
}
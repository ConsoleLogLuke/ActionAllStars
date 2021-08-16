package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.TradingCardDeleteEvent;
	import com.sdg.events.TradingCardDeletedEvent;
	
	import mx.rpc.IResponder;

	public class TradingCardDeleteCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:TradingCardDeleteEvent = event as TradingCardDeleteEvent;
			new SdgServiceDelegate(this).deleteTradingCard(ev.avatarId, ev.tradingCardId);
		}
		
		public function result(data:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new TradingCardDeletedEvent());
		}
	}
}
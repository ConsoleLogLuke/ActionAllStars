package com.sdg.commands
{
	import mx.rpc.IResponder;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.TradingCardSaveEvent;
		
	public class TradingCardSaveCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:TradingCardSaveEvent = event as TradingCardSaveEvent;
			new SdgServiceDelegate(this).saveTradingCard(ev.avatarId, ev.backgroundId, ev.items);
		}
		
		public function result(data:Object):void
		{
			trace("saveTradingCard response: " + XML(data));
		}
	}
}
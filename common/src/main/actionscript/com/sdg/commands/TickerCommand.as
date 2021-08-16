package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.TickerEvent;
	
	import mx.rpc.IResponder;
		
	public class TickerCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:TickerEvent = event as TickerEvent;
			new SdgServiceDelegate(this).getTickerFeed();
		}
		
		public function result(data:Object):void
		{
			//var data:Object = <SDGResponse status="1"/>;
			var xml:XML = XML(data);
			
			var games:XMLList = xml.games as XMLList;
			if (games && games.length() == 0)
				return;
				

			CairngormEventDispatcher.getInstance().dispatchEvent(new TickerEvent(TickerEvent.FEED_RECEIVED, XML(xml.games)));
		}
	}
}
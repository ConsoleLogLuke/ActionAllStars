package com.sdg.commands
{
	import mx.controls.Image;
	import mx.rpc.IResponder;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.TradingCardFrameEvent;
	import com.sdg.net.Environment;

	public class TradingCardFrameCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _frameImage:Image;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:TradingCardFrameEvent = event as TradingCardFrameEvent;
			_frameImage = ev.frameImage;
			
			// request the server for the trading card frame image
			new SdgServiceDelegate(this).getTradingCardFrame(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
			var xmlData:XML = data as XML;
			_frameImage.source = Environment.getApplicationUrl() + xmlData.tradingCardTemplate.frontLargeUrl;
		}
	}
}
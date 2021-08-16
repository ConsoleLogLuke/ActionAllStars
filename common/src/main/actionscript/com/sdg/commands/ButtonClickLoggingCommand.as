package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.ButtonClickLoggingEvent;
	
	import mx.rpc.IResponder;

	public class ButtonClickLoggingCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:ButtonClickLoggingEvent = event as ButtonClickLoggingEvent;
			
			// get the challenges from the server
			new SdgServiceDelegate(this).buttonClick(ev.linkId, ev.avatarId);
		}
		
		public function result(data:Object):void
		{
		}
	}
}
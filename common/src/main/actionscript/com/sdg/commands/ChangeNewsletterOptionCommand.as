package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlert;
	import com.sdg.events.ChangeNewsletterOptionEvent;
	
	import mx.rpc.IResponder;
	
	public class ChangeNewsletterOptionCommand implements ICommand, IResponder
	{
		private var _event:ChangeNewsletterOptionEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as ChangeNewsletterOptionEvent;
			new SdgServiceDelegate(this).changeNewsletterOption(_event.avatarId, _event.newsletterOptIn);
		}
		
		public function result(data:Object):void
		{
			getStatus(data);
		}
		
		public function fault(info:Object):void
		{
			getStatus(info);
			
			// get Better Info
			var status:int = int(info.@status);
			
			//SdgAlert.show("Error Saving Newsletter Opt-In/Out: "+status, "Time Out!", SdgAlert.OK);
		}
		
		private function getStatus(info:Object):void
		{
			// get the status from our xml data object
			//trace(info);
			var status:int = int(info.@status);
			
			// dispatch a chat mode changed event
			CairngormEventDispatcher.getInstance().dispatchEvent(new ChangeNewsletterOptionEvent(_event.avatarId, _event.newsletterOptIn, ChangeNewsletterOptionEvent.OPTION_CHANGED, status));
		}
	}
}

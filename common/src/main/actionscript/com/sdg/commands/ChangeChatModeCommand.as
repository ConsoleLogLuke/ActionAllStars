package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlert;
	import com.sdg.events.ChangeChatModeEvent;
	
	import mx.rpc.IResponder;
	
	public class ChangeChatModeCommand implements ICommand, IResponder
	{
		private var _event:ChangeChatModeEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as ChangeChatModeEvent;
			new SdgServiceDelegate(this).changeChatMode(_event.avatarId, _event.chatMode);
		}
		
		public function result(data:Object):void
		{
			getStatus(data);
		}
		
		public function fault(info:Object):void
		{
			getStatus(info);
			//SdgAlert.show("Error saving chat mode", "Time Out!", SdgAlert.OK);
		}
		
		private function getStatus(info:Object):void
		{
			// get the status from our xml data object
			trace(info);
			var status:int = int(info.@status);
			
			// dispatch a chat mode changed event
			CairngormEventDispatcher.getInstance().dispatchEvent(new ChangeChatModeEvent(_event.avatarId, _event.chatMode, ChangeChatModeEvent.CHATMODE_CHANGED, status));
		}
	}
}

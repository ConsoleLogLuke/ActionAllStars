package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlert;
	import com.sdg.events.ChangePasswordEvent;
	
	import mx.rpc.IResponder;
	
	public class ChangePasswordCommand implements ICommand, IResponder
	{
		private var _event:ChangePasswordEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as ChangePasswordEvent;
			
			if (_event.eventType == ChangePasswordEvent.CHANGE_PASSWORD)
				new SdgServiceDelegate(this).changePassword(_event.userId, _event.oldPassword, _event.newPassword);
			else if (_event.eventType == ChangePasswordEvent.CHANGE_PARENT_PASSWORD)
				new SdgServiceDelegate(this).changeParentPassword(_event.userId, _event.oldPassword, _event.newPassword);
		}
		
		public function result(data:Object):void
		{
			getStatus(data);
		}
		
		public function fault(info:Object):void
		{
			getStatus(info);
			//if (getStatus(info) == 0)
				//SdgAlert.show("Error saving password", "Time Out!", SdgAlert.OK);
		}
		
		private function getStatus(info:Object):int
		{
			// get the status from our xml data object
			trace(info);
			var status:int = int(info.@status);
			
			// dispatch a password changed event
			if (_event.eventType == ChangePasswordEvent.CHANGE_PASSWORD)
				CairngormEventDispatcher.getInstance().dispatchEvent(new ChangePasswordEvent(_event.userId, _event.oldPassword, _event.newPassword, ChangePasswordEvent.PASSWORD_CHANGED, status));
			else if (_event.eventType == ChangePasswordEvent.CHANGE_PARENT_PASSWORD)
				CairngormEventDispatcher.getInstance().dispatchEvent(new ChangePasswordEvent(_event.userId, _event.oldPassword, _event.newPassword, ChangePasswordEvent.PARENT_PASSWORD_CHANGED, status));
			
			return status;
		}
	}
}
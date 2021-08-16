package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.events.RegistrationSaveEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.UserActionTypes;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.Constants;
	
	import mx.rpc.IResponder;
	
	public class RegistrationSaveCommand implements ICommand, IResponder
	{
		private var _event:RegistrationSaveEvent;
		private var _progressDialog:ProgressAlertChrome;
		private var _avatar:Avatar = ModelLocator.getInstance().avatar;
		
		public function execute(event:CairngormEvent):void
		{
			//_progressDialog = ProgressAlert.show("In Progress.  Please wait", "Creating Athlete", null, null, true);
			_progressDialog = ProgressAlertChrome.show("In Progress.  Please wait", "Creating Athlete", null, null, true);
			_event = event as RegistrationSaveEvent;
			new SdgServiceDelegate(this).saveRegistration(_event.obj);
		}
		
		public function result(data:Object):void
		{
			var buddyId:int = data.@buddyId;
			if (buddyId != 0)
				ModelLocator.getInstance().referFriend.avatarId = buddyId;
			
			getStatus(data);
			
			// Dispatch a socket event.
			// It signifies a user action of registration complete.
			var params:Object = new Object();
			params.actionType = UserActionTypes.REGISTRATION_COMPLETE;
			params.actionValue = '1';
			if (Constants.QUEST_ENABLED == true) SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.USER_ACTION, params);
		}
		
		public function fault(info:Object):void
		{
			getStatus(info);
			//SdgAlert.show("Error connecting to server. Please try again later.", "Time Out!", SdgAlert.OK);
		}
		
		private function getStatus(info:Object):void
		{
			// get the status from our xml data object
			var status:int = int(info.@status);
			
			// dispatch a "registrationSaved" event
			CairngormEventDispatcher.getInstance().dispatchEvent(new RegistrationSaveEvent(_event.obj, RegistrationSaveEvent.REGISTRATION_SAVED, status, info.@itemName));
			
			// close out progress dialog
			if (_progressDialog)
				_progressDialog.close();
		}
	}
}
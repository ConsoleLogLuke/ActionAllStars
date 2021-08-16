package com.sdg.control
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.model.NotificationIcon;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.Constants;
	
	public class PSAController
	{
		private static var _instance:PSAController;
		/**
		 * Constructor.
		 */
		public function PSAController()
		{
			if (_instance)
				throw new Error("PSAController is a singleton class. Use 'getInstance()' to access the instance.");
				
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
		}
		
		public static function getInstance():PSAController
		{
			if (_instance == null)
				_instance = new PSAController();
			return _instance;
		}
		
		// event handlers
		private function onPluginEvent(event:SocketEvent):void
		{
			switch (event.params.action)
			{
				case "psa":
					processMessage(XML(event.params.psa));
					break;
			}
		}
		
		private function processMessage(message:XML):void
		{
			// set up rws
			var clickHandler:Function;
			
			if (message.type == NotificationIcon.RWS)
			{
				if (RoomManager.getInstance().currentRoom != null && RoomManager.getInstance().currentRoom.roomType == Constants.ROOM_TYPE_RWS)
					return;
				
				clickHandler = rwsClick;
			}
			HudController.getInstance().addNewNotification(message.text, message.type, message.priority == 1, false, clickHandler);
		}
		
		private function rwsClick():void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, "public_129"));
		}
	}
}

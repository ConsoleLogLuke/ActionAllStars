package com.sdg.manager
{
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.events.SocketEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.MainUtil;
	
	import flash.events.EventDispatcher;

	public class NPCPopupManager extends EventDispatcher
	{
		protected static var _instance:NPCPopupManager;
		
		public function NPCPopupManager()
		{
			if (_instance == null)
			{
				super();
			}
			else
			{
				throw new Error("NPCPopupManager is a singleton class. Use 'getInstance()' to access the instance.");
			}
		}
		
		public static function GetInstance():NPCPopupManager
		{
			if (_instance == null)
			{
				_instance = new NPCPopupManager();
				init();
			}
			return _instance;
		}

		protected static function init():void
		{
			// Listen for socket events.
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private static function onPluginEvent(e:SocketEvent):void
		{
			var params:Object = e.params;
			var action:String = params.action;
			
			if (action == "showDoodadPopup")
			{
				var itemId:String = params.doodadId;
				var popupId:String = params.popupId;

				// Log By ItemId  - I'm fudging b/c should be using inventoryId
				//    but it's safe b/c item Ids are too high to conflict with invIds
				LoggingUtil.sendSignClickLogging(parseInt(itemId));
				
				var urlIn:String = Environment.getAssetUrl()+"/test/swfDoodad/layer?layerId="+popupId+"&itemId="+itemId;
				
				MainUtil.showDialog(InteractiveDialog,{url:urlIn,id:104},false,false);
			}
			
		}
		
	}
}
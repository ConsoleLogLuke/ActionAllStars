package com.sdg.components.controls
{
	import flash.events.Event;
	
	public class CustomMVPAlert extends CustomAlert
	{
		public function CustomMVPAlert()
		{
			super();
		}
		
		/**
		 * Static show method.
		 */
		public static function show(url:String, goMvpIdentifier:int = -1, closeHandler:Function = null, eventIdentifierMap:Object = null):CustomMVPAlert
		{
			var alert:CustomMVPAlert = new CustomMVPAlert();
			alert.showMVP(url, goMvpIdentifier, closeHandler, eventIdentifierMap);
			return alert;
		}
		
		public function showMVP(url:String, goMvpIdentifier:int = -1, closeHandler:Function = null, eventIdentifierMap:Object = null):void
		{
			if (eventIdentifierMap == null)
				eventIdentifierMap = new Object();
			
			eventIdentifierMap["go mvp"] = goMvpIdentifier;
			eventIdentifierMap["close"] = -1;
			
			super.show(url, closeHandler, eventIdentifierMap);
		}
	}
}
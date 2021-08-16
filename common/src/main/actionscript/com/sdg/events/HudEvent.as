package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class HudEvent extends CairngormEvent
	{
		public static const HUD_EVENT:String = "hudEvent";
		public static const NOTIFICATION:String = "notification";
		public static const DELETE_NOTIFICATION:String = "deleteNotification";
		public static const BUDDY_REQUEST:String = "buddyRequest";
		public static const CARD_REQUEST:String = "cardRequest";
		public static const CHAT_MESSAGE:String = "chatMessage";
		public static const REPLY_BUDDY:String = "replyBuddy";
		public static const REPLY_CARD:String = "replyCard";
		public static const FIND_REMOVE_BUDDY_REQUEST:String = "findRemoveBuddyRequest";
		public static const ROOM_CHANGE:String = "roomChange";
		
		private var _eventType:String;
		private var _params:Object;
		
		public function HudEvent(eventType:String, params:Object)
		{
			super(HUD_EVENT);
			_eventType = eventType;
			_params = params;
		}

		public function get eventType():String
		{
			return _eventType;
		}
		
		public function get params():Object
		{
			return _params;
		}
	}
}
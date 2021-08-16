package com.sdg.events
{

	import flash.events.Event;
	
	public class SocketRoomEvent extends SocketEvent
	{
		public static const CONFIG:String = "roomConfig";
		public static const JOIN:String = "userJoin";
		public static const EXIT:String = "userExit";
		public static const ENUMERATION:String = "roomEnumeration";
		public static const AVATAR_ACTION:String = "avatarAction";
		public static const DOODAD_ACTION:String = "doodadAction";
		public static const UPDATE:String = "update";
		public static const NUM_AVATARS:String = "numAvatars";
		public static const USER_ACTION:String = "userAction";
		public static const ACCEPT_QUEST:String = "acceptQuest";
		public static const PET_FOLLOW_MODE:String = "setPetFollowMode";
		
		public static const BOT_ADDED:String = "botAdded";
		public static const BOT_REMOVED:String = "botRemoved";
		
		public function SocketRoomEvent(type:String, params:Object)
		{
			super(type, params);
		}
		
		override public function clone():Event
		{
			return new SocketRoomEvent(type, params);
		}
	}
}
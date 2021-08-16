package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class BuddyEvent extends CairngormEvent
	{
		public static const BUDDY_REQUEST:String = "buddyRequest";
		private var _buddyName:String;
		private var _buddyAvatarId:int;
		
		public function BuddyEvent(avatarId:int, name:String = null, type:String = null)
		{
			if (type)
			{
				super(type);
				_buddyAvatarId = avatarId;
				_buddyName = name;
			}
		}
		
		public function get buddyName():String
		{
			return _buddyName;
		}
		
		public function get buddyAvatarId():int
		{
			return _buddyAvatarId;
		}
	}
}
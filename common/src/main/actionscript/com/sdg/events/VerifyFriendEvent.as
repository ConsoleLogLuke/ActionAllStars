package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class VerifyFriendEvent extends CairngormEvent
	{
		public static const VERIFY_FRIEND:String = "verify friend";
		public static const FRIEND_VERIFIED:String = "friend verified";
		
		private var _friendName:String;
		private var _status:Boolean;
		
		public function VerifyFriendEvent(friendName:String, type:String = VERIFY_FRIEND, status:Boolean = false)
		{
			super(type);
			_friendName = friendName;
			_status = status;
		}
		
		public function get friendName():String
		{
			return _friendName;
		}
		
		public function get status():Boolean
		{
			return _status;
		}
	}
}

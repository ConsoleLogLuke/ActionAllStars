package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.model.Avatar;
	
	public class GuestAccountEvent extends CairngormEvent
	{
		public static const SAVE_GUEST:String = "saveGuest";
		public static const REENABLE_BUTTON:String = "reenableButton";
		
		private var _avatar:Avatar;
		
		public function GuestAccountEvent(avatar:Avatar, type:String = SAVE_GUEST)
		{
			super(type);
			this._avatar = avatar;
		}
		
		public function get avatar():Avatar
		{
			return _avatar;
		}
	}
}
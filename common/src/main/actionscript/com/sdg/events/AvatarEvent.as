package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ISetAvatar;

	public class AvatarEvent extends CairngormEvent
	{
		public static const AVATAR:String = "avatar";
		
		private var _avatarId:uint;
		private var _avatarReceiver:ISetAvatar;
		private var _avatarToUpdate:Avatar;
		
		public function AvatarEvent(avatarId:uint, avatarReceiver:ISetAvatar, avatarToUpdate:Avatar = null)
		{
			super(AVATAR);
			_avatarId = avatarId;
			_avatarReceiver = avatarReceiver;
			
			// Pass an avatar to update if you want to merge loaded avatar data.
			_avatarToUpdate = avatarToUpdate;
		}
		
		public function get avatarId():int
		{
			return _avatarId;
		}
		
		public function get avatarReceiver():ISetAvatar
		{
			return _avatarReceiver;
		}
		
		public function get avatarToUpdate():Avatar
		{
			return _avatarToUpdate;
		}
	}
}
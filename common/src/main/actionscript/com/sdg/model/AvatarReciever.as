package com.sdg.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class AvatarReciever extends EventDispatcher implements ISetAvatar
	{
		public static const AVATAR_SET:String = 'avatar set';
		
		protected var _avatar:Avatar;
		
		public function AvatarReciever()
		{
			super();
		}
		
		public function get avatar():Avatar
		{
			return _avatar;
		}
		public function set avatar(value:Avatar):void
		{
			_avatar = value;
			
			dispatchEvent(new Event(AVATAR_SET));
		}
		
	}
}
package com.sdg.events
{
	import flash.events.Event;

	public class DoodadActionEvent extends SocketEvent
	{
		public static const PET_LEASH:String = 'leash';
		public static const PET_UNLEASH:String = 'unleash';
		
		private var _id:int;
		private var _senderAvatarId:int;
		
		public function DoodadActionEvent(type:String, id:int, params:Object, senderAvatarId:int = 0)
		{
			super(type, params);
			
			_id = id;
			_senderAvatarId = senderAvatarId;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get senderAvatarId():int
		{
			return _senderAvatarId;
		}
		
	}
}
package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class ChangeChatModeEvent extends CairngormEvent
	{
		public static const CHANGE_CHATMODE:String = "changeChatMode";
		public static const CHATMODE_CHANGED:String = "chatModeChanged";
		
		private var _avatarId:uint;
		private var _chatMode:uint;
		private var _status:int;
		
		public function ChangeChatModeEvent(avatarId:uint, chatMode:uint, type:String = CHANGE_CHATMODE, status:int = 0)
		{
			super(type);
			this._avatarId = avatarId;
			this._chatMode = chatMode;
			this._status = status;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get chatMode():uint
		{
			return _chatMode;
		}
		
		public function get status():int
		{
			return _status;
		}
	}
}
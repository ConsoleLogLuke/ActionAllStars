package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class ChangeNewsletterOptionEvent extends CairngormEvent
	{
		public static const CHANGE_OPTION:String = "changeNewsletterOption";
		public static const OPTION_CHANGED:String = "newsletterOptionChanged";
		
		private var _avatarId:uint;
		private var _newsletterOptIn:uint;
		private var _status:int;
		
		public function ChangeNewsletterOptionEvent(avatarId:uint, newsletterOptIn:uint, type:String = CHANGE_OPTION, status:int = 0)
		{
			super(type);
			this._avatarId = avatarId;
			this._newsletterOptIn = newsletterOptIn;
			this._status = status;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get newsletterOptIn():uint
		{
			return _newsletterOptIn;
		}
		
		public function get status():int
		{
			return _status;
		}
	}
}
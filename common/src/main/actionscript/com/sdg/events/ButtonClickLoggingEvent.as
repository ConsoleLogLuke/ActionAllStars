package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ButtonClickLoggingEvent extends CairngormEvent
	{
		public static const BUTTON_CLICK_LOGGING:String = "button click logging";
		
		private var _linkId:int;
		private var _avatarId:int;
		
		public function ButtonClickLoggingEvent(linkId:int, avatarId:int = 0)
		{
			_linkId = linkId;
			_avatarId = avatarId;
			super(BUTTON_CLICK_LOGGING);
		}
		
		// properties
		public function get linkId():int
		{
			return _linkId;
		}
		
		public function get avatarId():int
		{
			return _avatarId;
		}
	}
}
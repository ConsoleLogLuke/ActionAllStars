package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ValidateUsernameEvent extends CairngormEvent
	{
		public static const VALIDATE_USERNAME:String = "validateUsername";
		public static const USERNAME_VALIDATED:String = "usernameValidated";
		
		private var _userName:String;
		private var _status:String;
		private var _suggestion:String;
		
		public function ValidateUsernameEvent(userName:String, type:String = VALIDATE_USERNAME, status:String = "unvalidated", suggestion:String = null)
		{
			super(type);
			_userName = userName;
			_status = status;
			_suggestion = suggestion;
		}
		
		public function get suggestion():String
		{
			return _suggestion;
		}
		
		public function get userName():String
		{
			return _userName;
		}
		
		public function get status():String
		{
			return _status;
		}
	}
}
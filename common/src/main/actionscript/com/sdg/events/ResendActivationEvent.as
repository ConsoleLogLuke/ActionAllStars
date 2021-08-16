package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class ResendActivationEvent extends CairngormEvent
	{
		public static const RESEND_ACTIVATION:String = "resendActivation";
		
		private var _userName:String;
		private var _email:String
		
		public function ResendActivationEvent(userName:String, email:String)
		{
			super(RESEND_ACTIVATION);
			this._userName = userName;
			this._email = email;
		}
		
		public function get userName():String
		{
			return _userName;
		}

		public function get email():String
		{
			return _email;
		}
	}
}

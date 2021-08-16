package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class RegistrationSaveEvent extends CairngormEvent
	{
		public static const SAVE_REGISTRATION:String = "saveRegistration";
		public static const REGISTRATION_SAVED:String = "registrationSaved";
		
		private var _obj:Object;
		private var _status:int;
		private var _giftName:String;
		
		public function RegistrationSaveEvent(obj:Object, type:String = SAVE_REGISTRATION, status:int = 0, giftName:String = null)
		{
			super(type);
			this._obj = obj;
			this._status = status;
			this._giftName = giftName;
		}
		
		public function get obj():Object
		{
			return _obj;
		}
		
		public function get status():int
		{
			return _status;
		}
		
		public function get giftName():String
		{
			return _giftName;
		}
	}
}
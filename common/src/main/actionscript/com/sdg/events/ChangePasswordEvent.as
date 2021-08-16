package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class ChangePasswordEvent extends CairngormEvent
	{
		public static const CHANGE_PASSWORD:String = "changePassword";
		public static const PASSWORD_CHANGED:String = "passwordChanged";
		public static const CHANGE_PARENT_PASSWORD:String = "changeParentPassword";
		public static const PARENT_PASSWORD_CHANGED:String = "parentPasswordChanged";
		
		private var _userId:uint;
		private var _newPassword:String;
		private var _oldPassword:String;
		private var _eventType:String;
		private var _status:int;
		
		public function ChangePasswordEvent(userId:uint, oldPassword:String, newPassword:String, eventType:String, status:int = 0)
		{
			super(eventType);
			this._userId = userId;
			this._oldPassword = oldPassword;
			this._newPassword = newPassword;
			this._eventType = eventType;
			this._status = status;
		}
		
		public function get userId():uint
		{
			return _userId;
		}
		
		public function get oldPassword():String
		{
			return _oldPassword;
		}
		
		public function get newPassword():String
		{
			return _newPassword;
		}
		
		public function get eventType():String
		{
			return _eventType;
		}
		
		public function get status():int
		{
			return _status;
		}
	}
}
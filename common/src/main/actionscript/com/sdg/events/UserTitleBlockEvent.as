package com.sdg.events
{
	import flash.events.Event;

	public class UserTitleBlockEvent extends Event
	{
		public static const TURF_BUTTON_CLICK:String = 'turf button click';
		public static const USER_SELECT:String = 'user select';
		
		protected var _userId:uint;
		protected var _userName:String;
		protected var _teamId:uint;
		
		public function UserTitleBlockEvent(type:String, userId:uint, userName:String, teamId:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_userId = userId;
			_userName = userName;
			_teamId = teamId;
			
			super(type, bubbles, cancelable);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get userId():uint
		{
			return _userId;
		}
		
		public function get userName():String
		{
			return _userName;
		}
		
		public function get teamId():uint
		{
			return _teamId;
		}
		
	}
}
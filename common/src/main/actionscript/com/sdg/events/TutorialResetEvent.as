package com.sdg.events
{
 	import com.adobe.cairngorm.control.CairngormEvent;
 
 	public class TutorialResetEvent extends CairngormEvent
 	{
 		public static const TUTORIAL_RESET:String = "tutorialReset";
 		public static const EVENT_CHECK_TRUE:String = "eventCheckTrue";
 		public static const EVENT_CHECK_FALSE:String = "eventCheckFalse";
 		
		private var _avatarId:uint;
		private var _value:uint;
 		private var _result:String;
 		
 		public function TutorialResetEvent(avatarId:uint, value:int)
 		{
 			super(TUTORIAL_RESET);
			_avatarId = avatarId;
			_value = value;
 			_result = result;
 		}

		public function get avatarId():int
		{
			return _avatarId;
		}

		public function get value():int
		{
			return _value;
		}
 		
 		public function get result():String
 		{
 			return _result;
 		}
 	}
}

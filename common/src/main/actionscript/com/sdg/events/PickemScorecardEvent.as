package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class PickemScorecardEvent extends CairngormEvent
	{
		public static const GET_SCORECARD:String = "getScorecard";
		public static const SCORECARD_RECEIVED:String = "scorecardReceived";
		
		private var _avatarId:int;
		private var _params:Object;
		
		public function PickemScorecardEvent(avatarId:int, type:String = GET_SCORECARD, params:Object = null)
		{
			super(type);
			_avatarId = avatarId;
			_params = params;
		}
		
		public function get avatarId():int
		{
			return _avatarId;
		}
		
		public function get params():Object
		{
			return _params;
		}
	}
}
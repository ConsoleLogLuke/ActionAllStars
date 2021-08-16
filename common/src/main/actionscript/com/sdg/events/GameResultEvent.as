package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GameResultEvent extends CairngormEvent
	{
		public static const GAME_RESULT:String = "gameResult";
		
		private var _result:String;
		
		public function GameResultEvent(result:String)
		{
			super(GAME_RESULT);
			_result = result;
		}
		
		public function get result():String
		{
			return _result;
		}
	}
}
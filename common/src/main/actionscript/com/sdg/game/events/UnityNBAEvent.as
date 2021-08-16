package com.sdg.game.events
{
	import flash.events.Event;

	public class UnityNBAEvent extends Event
	{
		public static var DATA_CHANGE:String = "unity nba data change";
		public static var LOGO_LOADED:String = "unity nba team logo loaded";
		public static var MY_TEAM_VIEW_DONE:String = "unity nba my team view done";
		public static var OPPONENT_TEAM_SELECTED:String = "unity nba opponent team selected";
		public static var FINAL_SCORE_FINISH_CLICK:String = "unity nba final score finish click";
		public static var START_GAME:String = "unity nba start game";
		public static var QUIT_GAME:String = "unity nba quit game";
		public static var BACK_BUTTON_CLICK:String = "unity nba back button click";
		public static var GAME_RESULT:String = "unity nba game result";
		
		public function UnityNBAEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}
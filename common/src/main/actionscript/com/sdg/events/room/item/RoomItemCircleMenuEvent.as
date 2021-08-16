package com.sdg.events.room.item
{
	import flash.events.Event;

	public class RoomItemCircleMenuEvent extends Event
	{
		public static const LOCAL_CIRCLE_MENU_ADDED_TO_STAGE:String = "LOCAL_CIRCLE_MENU_ADDED_TO_STAGE";
		public static const CIRCLE_MENU_REMOVED_FROM_STAGE:String = "CIRCLE_MENU_REMOVED_FROM_STAGE";
		
		public static const DESTROY:String = 'destroy';
		public static const HIDE_START:String = 'hide start';
		public static const HIDE_FINISH:String = 'hide finish';
		public static const SHOW_FINISH:String = 'show finish';
		
		public static const CLICK_FRIEND:String = 'click friend';
		public static const CLICK_HOME:String = 'click home';
		public static const CLICK_IGNORE:String = 'click ignore';
		public static const CLICK_INSPECT:String = 'click inspect';
		public static const CLICK_VISIT:String = 'click visit';
		public static const CLICK_INVITE:String = 'click invite';
		public static const CLICK_JAB:String = 'click jab';
		public static const CLICK_EMOTE:String = 'click emote';
		public static const CLICK_SHOP:String = 'click shop';
		public static const CLICK_PRINT:String = 'click print';
		public static const CLICK_MVP:String = 'click mvp';
		public static const CLICK_INVITE_TO_GAME:String = 'click invite to game';
		public static const CLICK_FEED_PET:String = 'click feed pet';
		public static const CLICK_PLAY_PET:String = 'click play pet';
		public static const CLICK_LEASH_PET:String = 'click leash pet';
		public static const CLICK_STAY_PET:String = 'click stay pet';
		
		private var _params:Object;
		
		public function RoomItemCircleMenuEvent(type:String, params:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_params = params;
		}
		
		public function get params():Object
		{
			return _params;
		}
		
	}
}
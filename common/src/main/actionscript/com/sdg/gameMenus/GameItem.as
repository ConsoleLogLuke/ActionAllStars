package com.sdg.gameMenus
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class GameItem extends EventDispatcher
	{
		public var id:int;
		public var name:String;
		public var tokens:int;
		protected var _owned:Boolean;
		
		public function GameItem()
		{
			super();
		}
		
		public function set owned(value:Boolean):void
		{
			_owned = value;
			dispatchEvent(new Event("ownedChanged"));
		}
		
		public function get owned():Boolean
		{
			return _owned;
		}
	}
}
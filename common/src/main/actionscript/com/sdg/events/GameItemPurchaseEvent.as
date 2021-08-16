package com.sdg.events
{
	import com.sdg.gameMenus.GameItem;
	
	import flash.events.Event;
	
	public class GameItemPurchaseEvent extends Event
	{
		public static const PURCHASE_ITEM:String = "purchase item";
		
		protected var _gameItem:GameItem;
		
		public function GameItemPurchaseEvent(gameItem:GameItem, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(PURCHASE_ITEM, bubbles, cancelable);
			
			_gameItem = gameItem;
		}
		
		public function get gameItem():GameItem
		{
			return _gameItem;
		}
	}
}
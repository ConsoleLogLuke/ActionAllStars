package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetKioskCardsEvent extends CairngormEvent
	{
		public static const GET_KIOSK_CARDS:String = "getKioskCardsEvent";
		public static const GET_KIOSK_CARDS_COMPLETED:String = "getKioskCardsCompleted";

		private var _avatarId:uint;
		private var _cards:Array;
		
		public function GetKioskCardsEvent(avatarId:int, type:String = GET_KIOSK_CARDS)
		{
			super(type);
			_avatarId = avatarId;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function set cards(value:Array):void
		{
			_cards = value;
		}
		
		public function get cards():Array
		{
			return _cards;
		}
	}
}
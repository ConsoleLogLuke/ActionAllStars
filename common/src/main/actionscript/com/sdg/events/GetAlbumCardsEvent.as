package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.model.TradingCard;

	public class GetAlbumCardsEvent extends CairngormEvent
	{
		public static const GET_ALBUM_CARDS:String = "getAlbumCards";
		public static const GET_ALBUM_CARDS_COMPLETED:String = "getAlbumCardsCompleted";
		
		private var _avatarId:uint;
		private var _cards:Array;
		
		public function GetAlbumCardsEvent(avatarId:uint, type:String = GET_ALBUM_CARDS)
		{
			super(type);
			_avatarId = avatarId;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get cards():Array
		{
			return _cards;
		}
		
		public function set cards(value:Array):void
		{
			_cards = value;
		}
	}
}
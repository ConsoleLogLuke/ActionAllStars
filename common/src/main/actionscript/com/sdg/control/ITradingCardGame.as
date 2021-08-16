package com.sdg.control
{
	public interface ITradingCardGame
	{
		
		function getTradingCards(params:Object):Object;
		
		function getAlbumCards(params:Object):Object;
		
		function close():void;
		
		function selectCard(params:Object):void;
		
		function acceptTrade(params:Object):void;
		
		function rejectTrade(params:Object):void;
		
		function cancelTrade(params:Object):void;
		
		function requestTrade(params:Object):void;

	}
}
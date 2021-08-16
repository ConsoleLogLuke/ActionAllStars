package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetAlbumCardsEvent;
	import com.sdg.model.TradingCard;
	import com.sdg.utils.ObjectUtil;
	import com.sdg.model.AvatarLevel;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;
		
	public class GetAlbumCardsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:GetAlbumCardsEvent = event as GetAlbumCardsEvent;
			new SdgServiceDelegate(this).getAlbumCards(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
	
			var cards:Array = new Array();
			
			// Ideally only be getting back a unique kiosk card here
			// as it stands we sometimes get duplicates so we can insure that we 
			// never have more than five if we set the index of the array
			for each (var item:XML in data.tradingCards.children())
			{
				var tc:TradingCard = ObjectUtil.mapXMLNodeValues(new TradingCard(),item);
				cards.push(tc);
			}
			// dispatch a "listCompleted" event	
			var ev:GetAlbumCardsEvent = new GetAlbumCardsEvent(ModelLocator.getInstance().avatar.avatarId, GetAlbumCardsEvent.GET_ALBUM_CARDS_COMPLETED);
			ev.cards = cards;
			
			CairngormEventDispatcher.getInstance().dispatchEvent(ev);
		}
	}
}
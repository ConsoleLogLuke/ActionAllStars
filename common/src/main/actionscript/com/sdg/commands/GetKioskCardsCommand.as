package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetKioskCardsEvent;
	import com.sdg.model.TradingCard;
	import com.sdg.utils.ObjectUtil;
	import com.sdg.model.AvatarLevel;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;
		
	public class GetKioskCardsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:GetKioskCardsEvent = event as GetKioskCardsEvent;
			new SdgServiceDelegate(this).getKioskCards(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
	
			var kioskCards:Array = new Array(AvatarLevel.MAX_LEVEL_NUMBER);
			
			// Ideally only be getting back a unique kiosk card here
			// as it stands we sometimes get duplicates so we can insure that we 
			// never have more than five if we set the index of the array
			for each (var item:XML in data.tradingCards.children())
			{
				var tc:TradingCard = ObjectUtil.mapXMLNodeValues(new TradingCard(),item);
				kioskCards[tc.avatarLevel - 1] = tc;
			}
			// dispatch a "listCompleted" event	
			var ev:GetKioskCardsEvent = new GetKioskCardsEvent(ModelLocator.getInstance().avatar.avatarId, GetKioskCardsEvent.GET_KIOSK_CARDS_COMPLETED);
			ev.cards = kioskCards;
			CairngormEventDispatcher.getInstance().dispatchEvent(ev);
		}
	}
}
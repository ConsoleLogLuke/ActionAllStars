package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.TradingCardBackgroundsEvent;
	import com.sdg.factory.SdgItemFactory;
	import com.sdg.model.InventoryItem;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;

	public class TradingCardBackgroundsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _backgrounds:ArrayCollection;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:TradingCardBackgroundsEvent = event as TradingCardBackgroundsEvent;
			_backgrounds = ev.backgrounds;
			
			// request the server for the backgrounds
			new SdgServiceDelegate(this).getTradingCardBackgrounds(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
			var xmlData:XML = data as XML;
			
			var factory:SdgItemFactory = new SdgItemFactory();
			_backgrounds.removeAll();
			
			for each (var item:XML in data.items.children())
			{
				factory.setXML(item);
				_backgrounds.addItem(InventoryItem(factory.createInstance()));
			}
		}
	}
}
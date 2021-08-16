package com.sdg.commands
{
	import mx.rpc.IResponder;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.InventoryAttributeSaveEvent;
	
	public class InventoryAttributeSaveCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:InventoryAttributeSaveEvent = event as InventoryAttributeSaveEvent;
			new SdgServiceDelegate(this).saveInventoryAttribute(ev.avatarId, ev.userIventoryId, ev.inventoryAttributeNameId, ev.inventoryAttributeValue, ev.cost);
		}
		
		public function result(data:Object):void
		{
			trace("InventoryAttributeSave response: " + XML(data));
		}
	}
}
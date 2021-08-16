package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.ItemTypeListEvent;
	import com.sdg.model.InventoryItemType;
	import com.sdg.model.ModelLocator;
	import mx.collections.ArrayCollection;
	
	import mx.rpc.IResponder;

	public class ItemTypeListCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _itemClassId:uint;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:ItemTypeListEvent = event as ItemTypeListEvent;
						
			_itemClassId = ev.itemClassId;
			
			new SdgServiceDelegate(this).getItemTypeList(ev.itemClassId);
		}
		
		public function result(data:Object):void
		{
			// get the list we will be populating
			var list:ArrayCollection = ModelLocator.getInstance().inventoryItemTypes[_itemClassId] as ArrayCollection;
			if (list == null)
			{
				list = new ArrayCollection;
				ModelLocator.getInstance().inventoryItemTypes[_itemClassId] = list;
			}
			
			// now populate the list			
			var xmlData:XML = data as XML;
			for each (var itemTypeXml:XML in xmlData.itemType)
			{
				var inventoryItemType:InventoryItemType = 
					new InventoryItemType(itemTypeXml.itemTypeId, itemTypeXml.name, itemTypeXml.itemClassId);
					
				list.addItem(inventoryItemType);													
			}
		}
	}
}
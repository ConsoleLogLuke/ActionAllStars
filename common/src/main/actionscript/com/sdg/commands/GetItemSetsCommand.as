package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.model.ItemSet;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;
	
	public class GetItemSetsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{	
		public function execute(event:CairngormEvent):void
		{ 
			new SdgServiceDelegate(this).getItemSets();
		}
		
		public function result(data:Object):void
		{
			// create new itemSet hashtable
			var itemSetMap:Object = new Object();
			
			// get the itemSets from our XML
			var xmlData:XML = data as XML;
			for each (var itemSetXml:XML in xmlData.itemSets.itemSet)
			{
				// get the item types ids
				var itemTypes:Array = new Array();
				for each (var itemTypeXml:XML in itemSetXml.itemSetItemTypes.itemSetItemType)
				{
					var itemTypeId:int = itemTypeXml.itemTypeId;
					itemTypes.push(itemTypeId);
				}
				
				// create a new itemSet
				var itemSet:ItemSet = new ItemSet(itemSetXml.itemSetId,	itemSetXml.name, itemSetXml.description, itemTypes);
					
				// add the itemSet	
				itemSetMap[itemSet.itemSetId] = itemSet;
			}
			
			// set the itemSets in ModelLocator
			ModelLocator.getInstance().itemSetsMap = itemSetMap;			
		}
	}
}
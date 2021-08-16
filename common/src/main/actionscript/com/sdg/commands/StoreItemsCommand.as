package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.StoreItemsEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Store;
	import com.sdg.model.StoreCategory;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;

	public class StoreItemsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _categoryId:int;
		private var _storeId:int;
		private var _avatarId:uint;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:StoreItemsEvent = event as StoreItemsEvent;
						
			_storeId = ev.storeId;
			_categoryId = ev.parentCategoryId;
			_avatarId = ev.avatarId;
			
			// get the store categories from the server
			new SdgServiceDelegate(this).getStoreItems(ev.parentCategoryId, ev.avatarId);
		}
		
		public function result(data:Object):void
		{
			var xmlData:XML = data as XML;
			
			var items:ArrayCollection = null;
			var store:Store = ModelLocator.getInstance().stores[_storeId];
			var category:StoreCategory = store.getCategoryById(_categoryId);;
			for each (var itemXml:XML in xmlData.items.item)
			{
				// get the list we need to populate
				if (items == null)
				{	
					items = store.getItemsByCategoryId(_categoryId);
					
					// we should have an empty list here, but clear it just in case
					if (items.length > 0)
						items.removeAll();
				}
				
				// create a new StoryCategory object
				var storeItem:StoreItem = createStoreItem(itemXml);
					                  				
				// add the child items if this is a 'collection' storeItem
				if (storeItem.isGroup)
				{
					for each (var childItemXml:XML in itemXml.item)
					{
						var childItem:StoreItem  = createStoreItem(childItemXml);
						storeItem.childItems.push(childItem);
					}
				}	                  				
				
				// now add the storeItem to the ArrayCollection
				items.addItem(storeItem);	                  							
			}
			
			CairngormEventDispatcher.getInstance().dispatchEvent(new StoreItemsEvent(_storeId, _categoryId, _avatarId, StoreItemsEvent.COMPLETE));
			
			function createStoreItem(xml:XML):StoreItem
			{
				

				var storeItem:StoreItem = new StoreItem(
											xml.itemId, 
				              				xml.name,
				              				xml.description,
				              				xml.price,
				              				xml.itemTypeId,
				              				xml.itemClass,
				              				parseInt(xml.isGroup) != 0,
				              				parseInt(xml.qtyOwned),
				              				Environment.getApplicationUrl() + xml.previewUrl,
				              				Environment.getApplicationUrl() + xml.thumbnailUrl,
				              				category,
				              				xml.walkSpeedPercent.length() ? xml.walkSpeedPercent : 0,
				              				xml.cooldownSeconds.length() ? xml.cooldownSeconds : 0,
				              				xml.effectDurationSecond.length() ? xml.effectDurationSecond : 0,
				              				xml.charges.length() ? xml.charges : 0,
				              				xml.levelRequirement.length() ? xml.levelRequirement : 0,
				              				xml.itemSetId.length() ? xml.itemSetId : 0,
				              				null,
				              				xml.HomeTurfValue.length() ? xml.HomeTurfValue : 0);
			
	            return storeItem; 				
			}
		}
	}
}
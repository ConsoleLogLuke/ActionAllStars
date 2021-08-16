package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.StoreCategoriesEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Store;
	import com.sdg.model.StoreCategory;
	import com.sdg.net.Environment;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;

	public class StoreCategoriesCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:StoreCategoriesEvent = event as StoreCategoriesEvent;
			
			// get the store categories from the server
			var delegate:SdgServiceDelegate = new SdgServiceDelegate(this);
			if (ev.storeId != -1)
				delegate.getStoreCategoriesByStoreId(ev.storeId);
			else	
				delegate.getStoreCategories(ev.parentCategoryId);
		}
		 
		public function result(data:Object):void
		{
			var xmlData:XML = data as XML;
			
			var store:Store;
			var categoryList:ArrayCollection = null;
			for each (var categoryXml:XML in xmlData.category)
			{
				// get the list we need to populate
				if (categoryList == null)
				{
					store = ModelLocator.getInstance().stores[categoryXml.storeId];
					if (store == null) continue;
					
					var parentId:int = categoryXml.parentCategoryId;
					if (parentId == 0)
						categoryList = store.rootCategories;
					else	
						categoryList = store.getCategoriesByParentId(parentId);
					
					// we should have an empty list here, but clear it just in case
					if (categoryList.length > 0)
						categoryList.removeAll();
				}
				
				// create a new StoryCategory object
				var category:StoreCategory = new StoreCategory(
													categoryXml.name, 
					                  				categoryXml.categoryId,
					                  				categoryXml.storeId,
					                  				categoryXml.categoryCount,
					                  				Environment.getApplicationUrl() + categoryXml.thumbnailUrl,
					                  				parentId);
				
				// add this category to the store's hashtable collection
				store.AddCategory(category);
				
				// now add it to the ArrayCollection
				categoryList.addItem(category);	                  							
			}
			
			if (store == null) return;
			
			CairngormEventDispatcher.getInstance().dispatchEvent(new StoreCategoriesEvent(-1, store.id, StoreCategoriesEvent.COMPLETE));
		}
	}
}
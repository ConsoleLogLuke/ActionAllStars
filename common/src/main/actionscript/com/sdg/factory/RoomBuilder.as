package com.sdg.factory
{
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.RoomEnumEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Room;
	import com.sdg.model.SdgItem;
	import com.sdg.utils.Constants;
	
	import flash.display.Bitmap;
	
	public class RoomBuilder
	{
		protected var itemFactory:SdgItemFactory = new SdgItemFactory();
		protected var roomFactory:RoomFactory = new RoomFactory();
		protected var room:Room;
		
		public function getRoom():Room
		{
			return room;
		}
		
		/**
		 * Creates a new Room instance.
		 */
		public function buildRoom(roomXML:XML):void
		{
			// Create a new room instance.
			roomFactory.setXML(roomXML);
			room = Room(roomFactory.createInstance());
		}
		
		public function updateRoom(roomXML:XML):void
		{
			roomFactory.setXML(roomXML);
			roomFactory.updateRoom(room);
		}
		
		/**
		 * Adds room elements described by the specified xml.
		 */
		public function buildEnumeration(enumXML:XML):void
		{
			var itemNode:XML;
			
			// Remove all current room items.
			room.removeAllItems();
			RoomManager.getInstance().itemCount = 0;
			room.isEnumRefreshed = false;
			
			// Build inventory items.
			for each (itemNode in enumXML.i)
			{
				buildItem(itemNode);
				RoomManager.getInstance().itemCount++;
			}
			
			// get the sprite sheets item ids we'll be caching
			getSpriteSheetIdsToBeCached(enumXML);
			
			// Add the user avatar.
			room.addItem(ModelLocator.getInstance().avatar);
			
			// Build avatars.
			for each (itemNode in enumXML.avatar)
				buildItem(itemNode);
			
			room.isEnumRefreshed = true;
			room.dispatchEvent(new RoomEnumEvent(RoomEnumEvent.ENUM_REFRESH));
		}
		
		/**
		 * Adds room elements described by the specified xml.
		 */
		public function buildItems(itemsXML:XML):void
		{
			var itemList:XMLList = itemsXML.children();
			
			for each (var itemNode:XML in itemList)
			{
				buildItem(itemNode);
			}
		}
		
		/**
		 * Adds or updates the room item described by the specified xml.
		 */
		public function buildItem(itemXML:XML):void
		{
			// Set the xml on the itemFactory.
			itemFactory.setXML(itemXML);
			
			// Check for an existing item with matching ids.
			var item:SdgItem = room.getItemByKey(itemFactory.getInstanceKey());
			
			if (item == null)
			{
				if (itemXML.name() == "avatar")
				{
					var modelAvatar:Avatar = ModelLocator.getInstance().avatar;
					
					if (itemXML.aId == modelAvatar.avatarId)
					{
						item = modelAvatar;
					}
				}
			}
			
			// If no item exists, create it and add it to the room.						
			if (item == null)
			{
				item = SdgItem(itemFactory.createInstance());
				room.addItem(item);
			}
			// If the item exists, update it.
			else
			{
				itemFactory.updateInstance(item);
			}
		}
		
		private function getSpriteSheetIdsToBeCached(enumXML:XML): void
		{
			// the maximum expanded spritesheets to cache
			var maxSpriteSheetsToCache:int = 20;
			
			// if a sprite sheet in any one room reaches this threshold count
			// it will be permanently cached 
			var permCacheThreshold:int = 7;
			
			// get the most used sprite sheets - we'll be caching those
			var itemsToCache:Object = new Object();
			
			// get the apparel items from the <clothingItemId> node 
			for each (var itemNode:XML in enumXML.avatar)
			{
				if (itemNode.cl == undefined)
					continue;
				
				// get the count for each item id	
				var apparelItems:Array = String(itemNode.cl).split(";");
				for each (var apparelItem:String in apparelItems)
				{
					if (apparelItem.length < 2)
						continue;
						
					// just get the eyes and mouth once
					var itemTypeId:int = String(apparelItem).split(",")[1];
					if (itemTypeId == 2 || itemTypeId == 3)
						continue;	
					
					// how many times will we be using this spritesheet so far...
					var count:int = itemsToCache[apparelItem] != null ? itemsToCache[apparelItem] : 0;
					itemsToCache[apparelItem] = ++count;
				}
			}

			// save the top 25 most used items 
			var itemsToCacheArray:Array = new Array();
			for (var itemKey:String in itemsToCache)
			{
				count = itemsToCache[itemKey];
					
				if (count > 1)
					itemsToCacheArray.push({itemKey:itemKey, count:count});
			}
			
			// sort on count
			itemsToCacheArray.sortOn("count", Array.NUMERIC | Array.DESCENDING);
			
			// limit the cache to 25
			if (itemsToCacheArray.length > maxSpriteSheetsToCache)
				itemsToCacheArray.splice(maxSpriteSheetsToCache);
				
			// now create our final container, complete with item,layer combo
			var permItems:Object = new Object();
			var nonPermItems:Object = new Object();
			for each (var item:Object in itemsToCacheArray)
			{
				var strs:Array = String(item.itemKey).split(",");
				var itemId:int = strs[0]
				itemTypeId = strs[1];
				
				// permantely cache items with a count > 4
				itemsToCache = item.count >= permCacheThreshold ? permItems : nonPermItems;
				
				// now add the items, to be cached, by itemId/layerId
				switch (itemTypeId)
				{
					case 1:
						itemsToCache[itemId + "/" + Constants.LAYER_SKIN] = itemTypeId;
						break;
					case 5:
						itemsToCache[itemId + "/" + Constants.LAYER_SHOES_LOWER] = itemTypeId;
						itemsToCache[itemId + "/" + Constants.LAYER_SHOES_UPPER] = itemTypeId;
						break;
					case 6:
						itemsToCache[itemId + "/" + Constants.LAYER_PANTS] = itemTypeId;
						break;
					case 7:
						itemsToCache[itemId + "/" + Constants.LAYER_SHIRT_LOWER] = itemTypeId;
						itemsToCache[itemId + "/" + Constants.LAYER_SHIRT_TORSO] = itemTypeId;
						itemsToCache[itemId + "/" + Constants.LAYER_SHIRT_UPPER] = itemTypeId;
						break;
					case 8:
						itemsToCache[itemId + "/" + Constants.LAYER_HAIR] = itemTypeId;
						break;
					case 9:
						itemsToCache[itemId + "/" + Constants.LAYER_HAT] = itemTypeId;
						break;
					default:	
						break;
				}
			}
			
			// store our 'items to cache' in ModelLocator
			ModelLocator.getInstance().expandedSpriteSheetsToCachePerm = permItems;
			ModelLocator.getInstance().expandedSpriteSheetsToCache = nonPermItems;
			 	
			// create the new non-perm Bitmap cache  
			var newBitmapCache:Object = new Object();
			
			// add any Bitmaps already cached in the old Bitmap cache that we still need
			var permBitmapCache:Object = ModelLocator.getInstance().expandedSpriteSheetBitmapsPerm;
			var oldBitmapCache:Object = ModelLocator.getInstance().expandedSpriteSheetBitmaps;
			for (var key:String in nonPermItems)
			{
				// first, see if we've already permanently cached this item
				if (permBitmapCache[key] != null)
				{
					nonPermItems[key] = null;
					continue;
				}
				
				// now put any bitmaps found in our old nonPermCache into our new nonPermCache
				var bitmap:Bitmap = oldBitmapCache[key] as Bitmap;
				if (bitmap != null)
				{
					newBitmapCache[key] = bitmap;
					oldBitmapCache[key] = null;
				}
			}
			
			ModelLocator.getInstance().expandedSpriteSheetBitmaps = newBitmapCache;
		}
	}
}
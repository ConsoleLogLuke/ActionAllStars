package com.sdg.model
{
	import com.sdg.collections.QuickList;
	import com.sdg.collections.QuickMap;
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.events.RoomEnumEvent;
	import com.sdg.sim.map.SimpleTile;
	import com.sdg.sim.map.TileMap;
	import com.sdg.sim.map.TileSet;
	import com.sdg.sim.map.TileSetCollection;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	/**
	 * The Room class describes room configuration and provides methods
	 * for containing and retrieving sets of SdgItems.
	 */
	[Bindable]
	public class Room extends EventDispatcher
	{
		public static const ITEM_VALID_FLAG:int = 0x01;
		public static const SPORTS_LOBBY:String = 'public_129';
		
		public var id:String;
		public var roomType:uint;
		public var storeId:uint;
		public var name:String;
		public var description:String;
		public var ownerId:int;
		public var ownerName:String;
		public var backgroundUrl:String;
		public var bgSwfUrl:String;			// url of tutorial swf
		public var bgHelpTextUrl:String;	// url of tutorial text.xml
		public var firstUser:int;			// non zero on first entry
		public var editMode:Boolean = false;
		public var themeId:int;
		public var layoutId:int;
		public var isEnumRefreshed:Boolean;
		
		private var clientItems:QuickMap = new QuickMap();
		private var items:QuickMap = new QuickMap();
		protected var itemFlags:QuickMap = new QuickMap(true);
		protected var mapLayers:QuickList = new QuickList();
		protected var _tileSets:TileSetCollection;
		
		protected var _roomActionListeners:Object;
		private var _backgroundMusicSoundId:String;
		private var _clientBackgroundMusicSoundId:String;
		private var _backgroundMusicVolume:Number;
		
		public function get numLayers():uint
		{
			return mapLayers.length;
		}
		
		/**
		 * Constructor.
		 */
		public function Room():void
		{
			// create room action listeners object
			_roomActionListeners = new Object();
			
			// Set default values.
			_backgroundMusicSoundId = '';
			_backgroundMusicVolume = 1;
		}
		
		public function setMapLayer(index:uint, map:TileMap):void
		{
			mapLayers[index] = map;
		}
		
		public function getMapLayer(index:uint):TileMap
		{
			return mapLayers[index];
		}
		
		public function getMapLayerIndex(tileMap:TileMap):int
		{
			return mapLayers.indexOf(tileMap);
		}
		
		public function removeMapLayer(index:uint):void
		{
			mapLayers.remove(index);
		}
		
		public function getValidMapForEntity(entity:RoomEntity, mapLayerIdsToCheck:Array):TileMap
		{
			var i:uint = 0;
			var len:uint = mapLayerIdsToCheck.length;
			for (i; i < len; i++)
			{
				var mapLayerId:uint = mapLayerIdsToCheck[i] as uint;
				var tileMap:TileMap = getMapLayer(mapLayerId);
				if (tileMap == null) continue;
				
				var isValid:Boolean = tileMap.validateOccupancy(entity, entity.x, entity.y);
				
				if (isValid) return tileMap;
			}
			
			return null;
		}
		
		/**
		 * Adds the specified item.
		 *	
		 * @param item The SdgItem to add.
		 */
		public function addItem(item:SdgItem):void
		{
			var key:String = SdgItemUtil.getInstanceKey(item);
			
			if (items.containsKey(key))
				removeItem(item);
			
			items.set(key, item);
			itemFlags[item] |= ITEM_VALID_FLAG;
			
			dispatchEvent(new RoomEnumEvent(RoomEnumEvent.ITEM_ADDED, item));
		}
		
		public function addClientItem(item:SdgItem):void
		{
			var key:String = SdgItemUtil.getInstanceKey(item);
			
			if (clientItems.containsKey(key)) removeClientItem(item);
			
			clientItems.set(key, item);
			
			dispatchEvent(new RoomEnumEvent(RoomEnumEvent.ITEM_ADDED, item));
		}
		
		public function removeClientItem(item:SdgItem):void
		{
			var key:String = clientItems.removeValue(item);
			if (key) dispatchEvent(new RoomEnumEvent(RoomEnumEvent.ITEM_REMOVED, item));
		}
		
		public function containsItem(item:SdgItem):Boolean
		{
			return items.contains(item);
		}
		
		public function containsItemKey(key:Object):Boolean
		{
			var item:SdgItem = key as SdgItem;
			if (item != null) key = SdgItemUtil.getInstanceKey(item);
			return items.containsKey(key);
		}
		
		/**
		 * Flags the specified item.
		 *	
		 * @param item The SdgItem to flag.
		 * @param flags The bit flags.
		 * @param value The Boolean value for each flag.
		 */
		public function flagItem(item:SdgItem, flags:int, value:Boolean):void
		{
			if (value)
				itemFlags[item] |= flags;
			else
				itemFlags[item] &= ~flags;
		}
		
		/**
		 *	Returns the item at the specified ids.
		 *
		 *	@param key The class id of the item.
		 */
		public function getItemByKey(key:Object):SdgItem
		{
			var item:SdgItem = key as SdgItem;
			if (item != null) key == SdgItemUtil.getInstanceKey(item);
			return items.get(key);
		}
		
		public function getAvatarById(id:uint):Avatar
		{
			return items.get(SdgItemUtil.generateKey(Avatar, id));
		}
		
		public function getInventoryItemById(id:uint):InventoryItem
		{
			return items.get(SdgItemUtil.generateKey(InventoryItem, id));
		}
		
		public function flagAllItems(flag:int, value:Boolean):void
		{
			for each (var item:SdgItem in items)
				flagItem(item, flag, value);
		}
		
		public function getAllItems():Array
		{
			return items.toArray();
		}
		
		public function getAllAvatars():Array
		{
			return getItemsByClass(Avatar);
		}
		
		public function getAllInventoryItems():Array
		{
			return getItemsByClass(InventoryItem);
		}
		
		public function getItemsByClass(itemClass:Class):Array
		{
			var list:Array = [];
			
			for each (var item:SdgItem in items)
				if (item is itemClass) list.push(item);
			
			return list;
		}
		
		public function getItemsByFlags(flags:int):Array
		{
			var list:Array = [];

			for each (var item:SdgItem in items)
				if ((itemFlags[item] & flags) == flags) list.push(item);

			return list;
		}
		
		public function getValidItems():Array
		{
			return getItemsByFlags(ITEM_VALID_FLAG);
		}
		
		public function removeItem(item:SdgItem):void
		{
			var key:String = items.removeValue(item);
			itemFlags.remove(item);
			if (key) dispatchEvent(new RoomEnumEvent(RoomEnumEvent.ITEM_REMOVED, item));
		}
		
		public function removeItemByKey(key:Object):SdgItem
		{
			var item:SdgItem = key as SdgItem;
			if (item != null) key == SdgItemUtil.getInstanceKey(item);
			
			item = items.remove(key);
			
			if (item) dispatchEvent(new RoomEnumEvent(RoomEnumEvent.ITEM_REMOVED, item));
			
			return item;
		}
		
		public function removeAvatarById(id:uint):Avatar
		{
			return removeItemByKey(SdgItemUtil.generateKey(Avatar, id)) as Avatar;
		}
		
		public function removeInventoryItemById(id:uint):InventoryItem
		{
			return removeItemByKey(SdgItemUtil.generateKey(InventoryItem, id)) as InventoryItem;
		}
		
		public function removeAllAvatars():void
		{
			removeItemsByClass(Avatar);
		}
		
		public function removeAllInventoryItems():void
		{
			removeItemsByClass(InventoryItem);
		}
		
		public function removeAllItems():void
		{
			for each (var item:SdgItem in items)
			{
				removeItem(item);
			}
		}
		
		public function removeAllClientItems():void
		{
			for each (var item:SdgItem in clientItems)
			{
				removeClientItem(item);
			}
		}
		
		public function removeInventoryItemsExceptWithTypeId(typeId:int):void
		{
			var allItemsCopy:Array = items.toArray();
			for(var i:int = allItemsCopy.length - 1; i >= 0; --i)
			{
				var item:InventoryItem = allItemsCopy[i];
				if (item != null)
				{
					if(item.itemTypeId != typeId)
					{
						removeItem(item);
					}
				}
			}
		}
		
		public function removeAllStaticItems():void
		{
			for each (var item:SdgItem in items)
			{
				if (item.isStatic == true) removeItem(item);
			}
		}
		
		public function removeItemsByClass(itemClass:Class):void
		{
			// There seems to be a bug in flash where the hashmap
			// is skipping if removing while iterating through.
			// using a shallow array copy seems to fix it.
			var allItemsCopy:Array = items.toArray();
			for(var i:int = allItemsCopy.length - 1; i >= 0; --i)
			{
				var item:SdgItem = allItemsCopy[i];
				if (item is itemClass)
				{
					removeItem(item);
				}
			}
			/*for each (var item:SdgItem in items)
				if (item is itemClass)
					removeItem(item);
			*/
		}
		
		public function addRoomActionListener(action:String, item:SdgItem):void
		{
			// listen for this action so we can process it on this item
			if (_roomActionListeners[action] != null)
			{
				(_roomActionListeners[action] as Array).push(item);
			}
			else
			{
				_roomActionListeners[action] = new Array(item);
			}
		}
		
		public function removeRoomActionListener(action:String, item:SdgItem):void
		{
			// stop listening for this action and processing it on this item
			var actionListeners:Array = _roomActionListeners[action] as Array;
			if (actionListeners == null) return;
			var index:int = actionListeners.indexOf(item);
			if (index >= 0) actionListeners.splice(index, 1);
		}
		
		public function removeExitTiles():void
		{
			// Set all exit tiles to simple walk tiles.
			
			var tileMap:TileMap = getMapLayer(RoomLayerType.FLOOR);
			var exitTileSets:TileSetCollection = _tileSets.getMultipleFromId(TileSet.EXIT_TILES);
			var i:uint = 0;
			var len:uint = exitTileSets.length;
			for (i; i < len; i++)
			{
				// Get exit tile set.
				var exitTileSet:TileSet = exitTileSets.getAt(i);
				var cols:uint = exitTileSet.cols;
				var rows:uint = exitTileSet.rows;
				var originX:int = exitTileSet.orginX;
				var originY:int = exitTileSet.orginY;
				
				// Set individual tiles.
				var exitTileArray:ByteArray = exitTileSet.byteArray;
				var i2:uint = 0;
				var len2:uint = exitTileArray.length;
				for (i2; i2 < len2; i2++)
				{
					exitTileArray.position = i2;
					
					// Make sure there should be a tile here.
					if (exitTileArray.readBoolean())
					{
						// Make a simple tile here.
						var tilePosition:Point = TileSet.GetPositionFromTileIndex(i2, cols, rows, originX, originY);
						tileMap.setTile(tilePosition.x, tilePosition.y, new SimpleTile());
					}
				}
			}
		}
		
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get roomActionListeners():Object
		{
			return _roomActionListeners;
		}
		
		public function get backgroundMusicSoundId():String
		{
			return _clientBackgroundMusicSoundId == null ? _backgroundMusicSoundId : _clientBackgroundMusicSoundId;
		}
		public function set backgroundMusicSoundId(value:String):void
		{
			_backgroundMusicSoundId = value;
		}
		public function set clientBackgroundMusicSoundId(value:String):void
		{
			_clientBackgroundMusicSoundId = value;
		}
		
		public function get backgroundMusicVolume():Number
		{
			return _backgroundMusicVolume;
		}
		public function set backgroundMusicVolume(value:Number):void
		{
			// Must be between 0 and 1.
			value = Math.max(value, 0);
			value = Math.min(value, 1);
			
			if (value == _backgroundMusicVolume) return;
			
			_backgroundMusicVolume = value;
		}
		
		public function get tileSets():TileSetCollection
		{
			return _tileSets;
		}
		public function set tileSets(value:TileSetCollection):void
		{
			_tileSets = value;
		}

	}
}
package com.sdg.factory
{
	import com.sdg.events.TriggerTileEvent;
	import com.sdg.model.Room;
	import com.sdg.model.RoomLayerType;
	import com.sdg.net.Environment;
	import com.sdg.sim.map.SimpleTile;
	import com.sdg.sim.map.TileGenerator;
	import com.sdg.sim.map.TileMap;
	import com.sdg.sim.map.TileSet;
	import com.sdg.sim.map.TileSetCollection;
	import com.sdg.sim.map.TriggerTile;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class RoomFactory extends AbstractXMLObjectFactory implements IXMLObjectFactory
	{
		public function createInstance():Object
		{
			var room:Room = new Room();
			updateRoom(room);
			
			return room;
		}
		
		public function updateRoom(room:Room):void
		{
			room.id = xml.id;
			room.name = xml.name;
			room.roomType = xml.roomType;
			room.storeId = xml.storeId;
			room.ownerId = xml.ownerId;
			room.backgroundUrl = Environment.getAssetUrl() + xml.backgroundUrl;
			//room.backgroundUrl = AssetUtil.GetRoomBackgroundUrl(xml.backgroundId);
			room.themeId = xml.themeId;
			room.layoutId = xml.roomId;
			room.bgSwfUrl =	Environment.getAssetUrl() + xml.tutorialSwfUrl;
			room.bgHelpTextUrl = Environment.getAssetUrl() + xml.tutorialTextUrl;
			room.firstUser = xml.firstUser;
			room.backgroundMusicSoundId =  (xml.soundId != null) ? xml.soundId : '';
			room.backgroundMusicVolume = (xml.soundId.@volume != null && String(xml.soundId.@volume).length > 0) ? Number(xml.soundId.@volume) / 100 : 1;
			room.tileSets = (xml.tiles) ? TileSet.TileSetCollectionFromEncodedString(xml.tiles) : new TileSetCollection;
			
			// Set map layers.
			room.setMapLayer(RoomLayerType.FLOOR, createTileMapFromRoom(room, TileSet.WALK_TILES));
			room.setMapLayer(RoomLayerType.LEFT_WALL, createTileMapFromRoom(room, TileSet.LEFT_WALL_TILES));
			room.setMapLayer(RoomLayerType.RIGHT_WALL, createTileMapFromRoom(room, TileSet.RIGHT_WALL_TILES));
			
			// Set exit tiles on floor layer.
			setExitTiles(room, RoomLayerType.FLOOR);

			// Set custom tiles on floor layer.
			setCustomTiles(room, RoomLayerType.FLOOR);
		}
		
		protected function createTileMapFromRoom(room:Room, tileSetId:uint):TileMap
		{
			// Get the tile set.
			var tileSet:TileSet = room.tileSets.getFromId(tileSetId);
			if (tileSet == null) return null;
			
			// Create an array that the TileMap class will like.
			var byteArray:ByteArray = tileSet.byteArray;
			var i:uint = 0;
			var len:uint = byteArray.length;
			var tileArray:Array = [len];
			for (i; i < len; i++)
			{
				byteArray.position = i;
				tileArray[i] = (byteArray.readBoolean()) ? '1' : '0';
			}
			
			var tileList:Array = TileGenerator.createTileList(tileArray, [null, SimpleTile], tileSetId.toString());
			var tileMap:TileMap = new TileMap(tileSet.cols, tileSet.rows, tileList, tileSet.orginX, tileSet.orginY);
			
			return tileMap;
		}
		
		protected function setExitTiles(room:Room, mapLayerId:uint):void
		{
			// Get reference to tile map.
			var tileMap:TileMap = room.getMapLayer(mapLayerId);
			if (tileMap == null) return;
			
			// Set exit tiles.
			var exitTileSets:TileSetCollection = room.tileSets.getMultipleFromId(TileSet.EXIT_TILES);
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
				
				// Create a trigger tile event for this tile set.
				var eventParams:Object = {eventName: 'exit', destination: 'public_' + exitTileSet.value};
				var exitTriggerEvent:TriggerTileEvent = new TriggerTileEvent(TriggerTileEvent.TILE_TRIGGER, eventParams);
				
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
						// Make an exit tile here.
						var tilePosition:Point = TileSet.GetPositionFromTileIndex(i2, cols, rows, originX, originY);
						tileMap.setTile(tilePosition.x, tilePosition.y, new TriggerTile(0, exitTriggerEvent));
					}
				}
			}
		}
		
		protected function setCustomTiles(room:Room, mapLayerId:uint):void
		{
			// Get reference to tile map.
			var tileMap:TileMap = room.getMapLayer(mapLayerId);
			if (tileMap == null) return;
			
			// Set custom tiles.
			var customTiles:TileSetCollection = room.tileSets.getMultipleFromId(TileSet.CUSTOM_TILES);
			var i:uint = 0;
			var len:uint = customTiles.length;
			for (i; i < len; i++)
			{
				// Get custom tile set.
				var customTileSet:TileSet = customTiles.getAt(i);
				var cols:uint = customTileSet.cols;
				var rows:uint = customTileSet.rows;
				var originX:int = customTileSet.orginX;
				var originY:int = customTileSet.orginY;
				
				// Create a trigger tile event for this tile set.
				var eventParams:Object = {eventName: 'tileSet', setID: customTileSet.value};
				var customTriggerTileEvent:TriggerTileEvent = new TriggerTileEvent(TriggerTileEvent.TILE_TRIGGER, eventParams);
				
				// Set individual tiles.
				var customTileArray:ByteArray = customTileSet.byteArray;
				var i2:uint = 0;
				var len2:uint = customTileArray.length;
				for (i2; i2 < len2; i2++)
				{
					customTileArray.position = i2;
					
					// Make sure there should be a tile here.
					if (customTileArray.readBoolean())
					{
						// Make a trigger tile here.
						var triggerTile:TriggerTile = new TriggerTile(0, customTriggerTileEvent);
						triggerTile.tileSetID = customTileSet.value;
						var tilePosition:Point = TileSet.GetPositionFromTileIndex(i2, cols, rows, originX, originY);
						tileMap.setTile(tilePosition.x, tilePosition.y, triggerTile);
					}
				}
			}
		}
		
	}
}
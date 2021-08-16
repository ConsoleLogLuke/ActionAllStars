package com.sdg.model
{
	import com.sdg.sim.map.TileSet;
	import com.sdg.sim.map.TileSetCollection;
	
	public class RoomConfig extends IdObject
	{
		protected var _avatarId:uint;
		protected var _backgroundId:uint;
		protected var _soundId:uint;
		protected var _storeId:uint;
		protected var _tileSets:TileSetCollection;
		protected var _soundVolume:int;
		
		public function RoomConfig(id:uint, name:String, avatarId:uint, backgroundId:uint, soundId:uint, soundVolume:int, storeId:uint, tileSets:TileSetCollection)
		{
			super(id, name);
			
			_avatarId = avatarId;
			_backgroundId = backgroundId;
			_soundId = soundId;
			_storeId = storeId;
			_tileSets = tileSets;
			_soundVolume = soundVolume;
		}
		
		public function getPayLoadString():String
		{
			// Return a payload XML string.
			
			// Parse tile sets into an encoded string.
			var i:uint = 0;
			var len:uint = _tileSets.length;
			var encodedTileSetString:String = '';
			for (i; i < len; i++)
			{
				var encodedTileSet:String = _tileSets.getAt(i).getEncodedString();
				encodedTileSetString += encodedTileSet;
				
				if (i < len - 1) encodedTileSetString += '|';
			}
			
			// Create room attributes.
			var attributesXML:XML = new XML('<attributes></attributes>');
			attributesXML.appendChild('<backgroundId>' + _backgroundId + '</backgroundId>');
			attributesXML.appendChild('<soundId volume="' + _soundVolume + '">' + _soundId + '</soundId>');
			attributesXML.appendChild('<storeId>' + _storeId + '</storeId>');
			attributesXML.appendChild('<tiles>' + encodedTileSetString + '</tiles>');
			
			// Create payload.
			var paylodXML:XML = new XML('<payload></payload>');
			paylodXML.appendChild('<roomId>' + _id + '</roomId>');
			paylodXML.appendChild(attributesXML);
			
			return paylodXML.toString();
		}
		
		public function getAttributesXML():XML
		{
			// Return attribute XML object.
			
			// Parse tile sets into an encoded string.
			var i:uint = 0;
			var len:uint = _tileSets.length;
			var encodedTileSetString:String = '';
			var encodingFormat:uint = TileSet.BIT_GROUP_FORMAT;
			for (i; i < len; i++)
			{
				var encodedTileSet:String = _tileSets.getAt(i).getEncodedString(encodingFormat);
				encodedTileSetString += encodedTileSet;
				
				if (i < len - 1) encodedTileSetString += '|';
			}
			
			// Create room attributes.
			var attributesXML:XML = new XML('<attributes></attributes>');
			attributesXML.appendChild('<backgroundId>' + _backgroundId + '</backgroundId>');
			attributesXML.appendChild('<soundId volume="' + _soundVolume + '">' + _soundId + '</soundId>');
			attributesXML.appendChild('<storeId>' + _storeId + '</storeId>');
			attributesXML.appendChild('<tiles>' + encodedTileSetString + '</tiles>');
			
			return attributesXML;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
		
		public function get backgroundId():uint
		{
			return _backgroundId;
		}
		
		public function get soundId():uint
		{
			return _soundId;
		}
		
		public function get soundVolume():int
		{
			return _soundVolume;
		}
		
		public function get storeId():uint
		{
			return _storeId;
		}
		
		public function get tileSets():TileSetCollection
		{
			return _tileSets;
		}
		
	}
}
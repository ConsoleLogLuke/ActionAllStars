package com.sdg.sim.map
{
	import com.sdg.model.IdObject;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class TileSet extends IdObject
	{
		public static const WALK_TILES:uint = 1;
		public static const SPAWN_TILES:uint = 2;
		public static const EXIT_TILES:uint = 3;
		public static const LEFT_WALL_TILES:uint = 4;
		public static const RIGHT_WALL_TILES:uint = 5;
		public static const CUSTOM_TILES:uint = 6;
		
		public static const LONG_FORMAT:uint = 1;
		public static const BIT_GROUP_FORMAT:uint = 2;
		
		protected var _byteArray:ByteArray;
		protected var _cols:uint;
		protected var _rows:uint;
		protected var _orginX:uint;
		protected var _orginY:uint;
		protected var _value:String;
		
		public function TileSet(id:uint, name:String, cols:uint, rows:uint, orginX:uint = 0, orginY:uint = 0, value:String = '', byteArray:ByteArray = null)
		{
			super(id, name);
			
			_cols = cols;
			_rows = rows;
			_orginX = orginX;
			_orginY = orginY;
			_value = value;
			_byteArray = (byteArray) ? byteArray : new ByteArray();
		}
		
		public static function TileSetCollectionFromEncodedString(encodedString:String):TileSetCollection
		{
			// Separate by pipes.
			var tileSetEncodedStrings:Array = encodedString.split('|');
			
			var i:uint = 0;
			var len:uint = tileSetEncodedStrings.length;
			var tileSets:TileSetCollection = new TileSetCollection();
			for (i; i < len; i++)
			{
				var tileSet:TileSet = TileSetFromEncodedString(tileSetEncodedStrings[i]);
				if (tileSet) tileSets.push(tileSet);
			}
			
			return tileSets;
		}
		
		public static function TileSetFromEncodedString(encodedString:String):TileSet
		{
			// Separate by colons.
			var valueCount:uint = 9;
			var values:Array = encodedString.split(':', valueCount);
			
			if (values.length < valueCount) return null;
			
			// Get values.
			var id:uint = values[0];
			var name:String = values[1];
			var cols:uint = values[2];
			var rows:uint = values[3];
			var orginX:uint = values[4];
			var orginY:uint = values[5];
			var value:String = values[6];
			var encodingFormat:uint = values[7];
			var byteString:String = values[8];
			
			// Create byte array.
			var byteArray:ByteArray = getByteArrayFromEncodedString(byteString, encodingFormat);
			
			// Create tile set.
			var tileSet:TileSet = new TileSet(id, name, cols, rows, orginX, orginY, value, byteArray);
			
			return tileSet;
		}
		
		public static function GetPositionFromTileIndex(tileIndex:uint, cols:uint, rows:uint, orginX:uint = 0, orginY:uint = 0):Point
		{
			var y:uint = Math.floor(tileIndex / cols);
			var x:uint = tileIndex - (y * cols);
			x -= orginX;
			y -= orginY;
			
			return new Point(x, y);
		}
		
		public function getEncodedString(format:uint = LONG_FORMAT):String
		{
			// Convert a byte array into an encoded string and return it.
			
			switch (format)
			{
				case LONG_FORMAT :
					return getLongFormatEncodedString(_byteArray);
				case BIT_GROUP_FORMAT :
					return getBitGroupFormatEncodedString(_byteArray);
				default :
					return '';
			}
		}
		
		protected static function getByteArrayFromEncodedString(encodedString:String, format:uint = LONG_FORMAT):ByteArray
		{
			// Convert a string into a byte array and return it.
			
			switch (format)
			{
				case LONG_FORMAT :
					return getByteArrayFromLongFormatEncodedString(encodedString);
				case BIT_GROUP_FORMAT :
					return getByteArrayFromBitGroupFormatEncodedString(encodedString);
				default :
					return null;
			}
		}
		
		protected function getLongFormatEncodedString(byteArray:ByteArray):String
		{
			var encodedString:String = _id + ':' + _name + ':' + _cols + ':' + _rows + ':' + _orginX + ':' + _orginY + ':' + _value + ':' + LONG_FORMAT.toString() + ':';
			
			// Convert byte array to string.
			var i:uint = 0;
			var len:uint = byteArray.length;
			var byteArrayString:String = '';
			for (i; i < len; i++)
			{
				byteArrayString += (byteArray[i]) ? '1' : '0';
			}
			
			encodedString += byteArrayString;
			
			return encodedString;
		}
		
		protected function getBitGroupFormatEncodedString(byteArray:ByteArray):String
		{
			var encodedString:String = _id + ':' + _name + ':' + _cols + ':' + _rows + ':' + _orginX + ':' + _orginY + ':' + _value + ':' + BIT_GROUP_FORMAT.toString() + ':';
			
			// Convert byte array to string.
			var i:uint = 0;
			var len:uint = byteArray.length;
			var byteArrayString:String = '';
			var runLength:uint = 0;
			var currentBit:Boolean = false;
			for (i; i < len; i++)
			{
				byteArray.position = i;
				
				if (byteArray.readBoolean() == currentBit)
				{
					runLength++;
				}
				else
				{
					byteArrayString += runLength.toString();
					if (i < len - 1) byteArrayString += ',';
					
					i--;
					runLength = 0;
					currentBit = !currentBit;
				}
			}
			
			if (currentBit)
			{
				if (runLength == 1) byteArrayString += ',';
				byteArrayString += runLength.toString();
			}
			
			encodedString += byteArrayString;
			
			return encodedString;
		}
		
		protected static function getByteArrayFromLongFormatEncodedString(encodedString:String):ByteArray
		{
			// Create byte array.
			var i:uint = 0;
			var len:uint = encodedString.length;
			var byteArray:ByteArray = new ByteArray();
			for (i; i < len; i++)
			{
				byteArray[i] = (encodedString.charAt(i) == '1') ? 1 : 0;
			}
			
			return byteArray;
		}
		
		protected static function getByteArrayFromBitGroupFormatEncodedString(encodedString:String):ByteArray
		{
			// Create byte array.
			var values:Array = encodedString.split(',');
			var i:uint = 0;
			var bitPosition:uint = 0;
			var len:uint = values.length;
			var byteArray:ByteArray = new ByteArray();
			var currentBit:Boolean = false;
			for (i; i < len; i++)
			{
				writeBits(currentBit, values[i]);
				
				currentBit = !currentBit;
			}
			
			return byteArray;
			
			function writeBits(value:Boolean, length:uint):void
			{
				var i:uint = 0;
				for (i; i < length; i++)
				{
					byteArray[bitPosition] = value;
					
					bitPosition++;
				}
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get cols():uint
		{
			return _cols;
		}
		
		public function get rows():uint
		{
			return _rows;
		}
		
		public function get orginX():uint
		{
			return _orginX;
		}
		
		public function get orginY():uint
		{
			return _orginY;
		}
		
		public function get value():String
		{
			return _value;
		}
		
		public function get byteArray():ByteArray
		{
			return _byteArray;
		}
		
	}
}
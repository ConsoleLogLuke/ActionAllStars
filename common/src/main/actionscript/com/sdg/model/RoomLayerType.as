package com.sdg.model
{
	public class RoomLayerType
	{
		public static const BACKGROUND:uint = 0;
		public static const WALL:uint = 1;
		public static const FLOOR:uint = 2;
		public static const FOREGROUND:uint = 3;
		public static const LEFT_WALL:uint = 4;
		public static const RIGHT_WALL:uint = 5;
		
		public static function isMapType(layerType:uint):Boolean
		{
			// Return TRUE if ;ayerType is of the type FLOOR or WALL.
			return (layerType == RoomLayerType.FLOOR || layerType == RoomLayerType.WALL || layerType == RoomLayerType.LEFT_WALL || layerType == RoomLayerType.RIGHT_WALL);
		}
	}
}
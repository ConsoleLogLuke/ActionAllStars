package com.sdg.model
{
	public class ItemType extends Object
	{
		// These values should refelct the 'ItemType' table on the database.
		public static const BODY:int = 1;
		public static const EYES:int = 2;
		public static const MOUTH:int = 3;
		public static const SOCKS:int = 4;
		public static const SHOES:int = 5;
		public static const PANTS:int = 6;
		public static const SHIRTS:int = 7;
		public static const HAIR:int = 8;
		public static const HAT:int = 9;
		public static const FURNITURE:int = 11;
		public static const SPORTS_EQ:int = 13;
		public static const GLASSES:int = 14;
		public static const VISOR:int = 15;
		public static const HEADBAND:int = 16;
		public static const HELMET:int = 17;
		public static const BEANIE:int = 18;
		public static const BOARD_GAME:int = 19;
		public static const PETS:int = 20;
		public static const PET_FOOD:int = 21;
		public static const BACKGROUNDS:int = 1019;
		public static const EXIT_POINT:int = 1020;
		public static const INTERACTIVE_DOODAD:int = 1021;
		public static const BACKGROUND_ITEM:int = 1022;
		public static const COLLECTIBLES:int = 1023;
		public static const NPC:int = 1024;
		public static const WALL_ITEM:int = 1026;
		public static const SUIT:int = 1032;
		
		public static function IsClothing(itemTypeId:int):Boolean
		{
			if (itemTypeId == SOCKS ||
				itemTypeId == SHOES ||
				itemTypeId == PANTS ||
				itemTypeId == SHIRTS ||
				itemTypeId == HAT ||
				itemTypeId == GLASSES ||
				itemTypeId == VISOR ||
				itemTypeId == HEADBAND ||
				itemTypeId == HELMET ||
				itemTypeId == BEANIE
				)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
	}
}
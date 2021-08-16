package com.sdg.utils
{
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	
	public class PreviewUtil
	{
		public static const BODY:int = 1;
		public static const EYES:int = 2;
		public static const MOUTH:int = 3;
		public static const SOCKS:int = 4;
		public static const SHOES:int = 5;
		public static const PANTS:int = 6;
		public static const SHIRTS:int = 7;
		public static const HAIR:int = 8;
		public static const HAT:int = 9;
		public static const GLASSES:int = 14;
		public static const VISOR:int = 15;
		public static const HEADBAND:int = 16;
		public static const HELMET:int = 17;
		public static const BEANIE:int = 18;
		public static const BOARD_GAME:int = 19;
		public static const PETS:int = 20;
		public static const BACKGROUNDS:int = 1019;
		public static const THEME:int = 1027;
		public static const SUITS:int = 1032;
		public static const PREVIEW_HAIR_A:int = 9000;
		public static const PREVIEW_HAIR_B:int = 9010;
		public static const PREVIEW_HAIR_C:int = 9011;
		public static const PREVIEW_HAIR_D:int = 9012;
		public static const PREVIEW_HAIR_E:int = 9013;
		
		private static const TYPE_MAP:Object = 
		{
		   20:{name:"pets", layerId:0},
		   1:{name:"body",     layerId:1},
		   2:{name:"eyes",     layerId:2},
		   3:{name:"mouth",    layerId:3},
		   4:{name:"socks",    layerId:4},
		   5:{name:"shoes",    layerId:5},
		   6:{name:"pants",    layerId:6},
		   7:{name:"shirts",   layerId:7},
		   8:{name:"hair",     layerId:8},
		   14:{name:"eyewear", layerId:9},
		   9:{name:"headwear", layerId:10},
		   15:{name:"headwear", layerId:10},
		   16:{name:"headwear", layerId:10},
		   17:{name:"headwear", layerId:10},
		   18:{name:"headwear", layerId:10},
		   1032:{name:"suits", layerId:11},
		   19:{name:"games", layerId:-1},
		   1019:{name:"backgrounds", layerId:12}
		};
		
		private static const LEVEL_COLOR_MAP:Object = 
		{
		   1:Constants.LEVEL_COLOR_AMATEUR,
		   2:Constants.LEVEL_COLOR_ROOKIE,
		   3:Constants.LEVEL_COLOR_PRO,
		   4:Constants.LEVEL_COLOR_VETERAN,
		   5:Constants.LEVEL_COLOR_ALLSTAR
		};
		
		public static function getLayerId(itemTypeId:int):int
        {
        	if (TYPE_MAP[itemTypeId] == null)
        		return -1;
        		
        	return TYPE_MAP[itemTypeId].layerId;
        }
        
        public static function getTypeNameById(id:uint):String
        {
        	if (TYPE_MAP[id] == null)
        		return null;
        		
        	return TYPE_MAP[id].name;
        }
        
        /**
        * Gets the hair layer id (HAIR A,B,C,D or E) the avatar needs for the headwear
        * that is currently on.
        * 
        * @param avatar  the avatar to get the layer id for.
        * @forSpriteSheet  if true a spritesheet layer id is returned, otherwise a Preview layer Id is returned. 
        */ 
        public static function getHairLayerId(avatar:Avatar, forSpriteSheet:Boolean = false, headwearType:int = 0):int
        {
        	var hair:InventoryItem = avatar.apparel.getItemAt(getLayerId(HAIR)) as InventoryItem;
        	if (!hair)
        		return 0;
        		
        	// get the hair style        	
        	var hairStyle:String = "";	
        	switch (hair.itemId)    	
        	{				 
				case 3465:
				case 3466:
				case 2631:
				case 3464:
					hairStyle = "afro";
					break;
				case 3486:
				case 3487:
				case 3488:
				case 3485:
					hairStyle = "grunge";
					break;
				case 3468:
				case 3469:
				case 3470:
				case 3467:
					hairStyle = "buzzcut";
					break;
				case 3483:
				case 2633:
				case 3484:
				case 3482:
					hairStyle = "greaser";
					break;
				case 2632:
				case 3476:
				case 3477:
				case 3475:
					hairStyle = "crewcut";
					break;
				case 3479:
				case 3480:
				case 3481:
				case 3478:
					hairStyle = "fade";
					break;
				case 3472:
				case 3473:
				case 3474:
				case 3471:
					hairStyle = "cleancut";
					break;
				case 3490:
				case 3491:
				case 3492:
				case 3489:
					hairStyle = "bob";
					break;
				case 3501:
				case 2977:
				case 3502:
				case 3500:
					hairStyle = "pigtail";
					break;
				case 3497:
				case 3498:
				case 3499:
				case 3496:
					hairStyle = "flower";
					break;
				case 3504:
				case 3505:
				case 3506:
				case 3503:
					hairStyle = "ptail3";
					break;
				case 3494:
				case 3495:
				case 2634:
				case 3493:
					hairStyle = "flip";
					break;
				case 2635:
				case 3508:
				case 3509:
				case 3507:
					hairStyle = "ptialHB";
					break;
				case 3511:
				case 3512:
				case 3513:
				case 3510:
					hairStyle = "swirl";
					break;
				default:
					return forSpriteSheet ? Constants.LAYER_HAIR : PREVIEW_HAIR_A;	
        	}

			var hairLayerId:int = forSpriteSheet ? Constants.LAYER_HAIR : PREVIEW_HAIR_A;
			var headwearTypeId:int = headwearType != 0 ? headwearType : avatar.getHeadwearType();
			switch (headwearTypeId)
			{
				case PreviewUtil.HAT:
					hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_WITH_HAT : PREVIEW_HAIR_B;
					break;
				case PreviewUtil.VISOR:
					switch (hairStyle)
					{
						case "afro":
						case "greaser":
						case "crewcut":
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_C : PREVIEW_HAIR_C;
							break;
						default:
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_WITH_HAT : PREVIEW_HAIR_B;
							break;
					}
					break;
				case PreviewUtil.HEADBAND:
					switch (hairStyle)
					{
						case "afro":
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_D : PREVIEW_HAIR_D;
							break;
						case "greaser":
						case "crewcut":
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_C : PREVIEW_HAIR_C;
							break;
						default:
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_WITH_HAT : PREVIEW_HAIR_B;
							break;
					}
					break;
				case PreviewUtil.HELMET:
				case PreviewUtil.BEANIE:
					switch (hairStyle)
					{
						case "afro":
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_E : PREVIEW_HAIR_E;
							break;
						case "flip":
						case "swirl":
						case "flower":
						case "pigtails":
						case "ptial3":
						case "ptialHB":
						case "greaser":
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_C : PREVIEW_HAIR_C;
							break;
						default:
							hairLayerId = forSpriteSheet ? Constants.LAYER_HAIR_WITH_HAT : PREVIEW_HAIR_B;
							break;
					}
					break;
				default:	
					break;
			}
			
			return hairLayerId;        
		}
		
		public static function isHeadwear(itemTypeId:int):Boolean
		{
			var isHeadwear:Boolean = 
				itemTypeId == PreviewUtil.HAT ||
				itemTypeId == PreviewUtil.HELMET ||
				itemTypeId == PreviewUtil.HEADBAND ||
				itemTypeId == PreviewUtil.VISOR ||
				itemTypeId == PreviewUtil.BEANIE;
			
			return isHeadwear;	
		}
		
		public static function getLevelColor(level:int):uint
		{
			var color:uint = uint(LEVEL_COLOR_MAP[level]);
			
			return color;
		}
		
		public static function getSubLevelColor(subLevel:uint):uint
		{
			var levelIndex:int = Math.ceil(subLevel / 5);
			var color:uint = LEVEL_COLOR_MAP[levelIndex];
			
			return color;
		}
		
		public static function getAvatarLevelColor(avatar:Avatar):uint
		{
			var level:int = avatar ? avatar.level : 0;
			return getLevelColor(level);
		}
		
		public static function getTextColor(level:int):uint
		{
			var color:uint;
			switch (level)
			{
				case 1:
					color = Constants.LEVEL_COLOR_AMATEUR_TEXT;
					break;
				case 2:
					color = Constants.LEVEL_COLOR_ROOKIE_TEXT;
					break;
				case 3:
					color = Constants.LEVEL_COLOR_PRO_TEXT;
					break;
				case 4:
					color = Constants.LEVEL_COLOR_VETERAN_TEXT;
					break;
				case 5:
					color = Constants.LEVEL_COLOR_ALLSTAR_TEXT;
					break;
				default:
					color = Constants.LEVEL_COLOR_ROOKIE_TEXT;
					break;
			}
			
			return color;
		}
		
		public static function getAvatarTextColor(avatar:Avatar):uint
		{
			var level:int = avatar ? avatar.level : 0;
			
			return getTextColor(level);
		}
	}
}

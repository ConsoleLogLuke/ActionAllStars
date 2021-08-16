package com.sdg.utils
{
	import com.sdg.model.Hair;
	import com.sdg.model.HeadWear;
	
	public class HairUtil extends Object
	{
		public static const HAIR_A:int = 9000;
		public static const HAIR_B:int = 9010;
		public static const HAIR_C:int = 9011;
		public static const HAIR_D:int = 9012;
		public static const HAIR_E:int = 9013;
		
		private static const types:Object =
		{
			'3465' : Hair.AFRO,
			'3466' : Hair.AFRO,
			'2631' : Hair.AFRO,
			'3464' : Hair.AFRO,
			
			'3486' : Hair.GRUNGE,
			'3487' : Hair.GRUNGE,
			'3488' : Hair.GRUNGE,
			'3485' : Hair.GRUNGE,
			
			'3468' : Hair.BUZZ_CUT,
			'3469' : Hair.BUZZ_CUT,
			'3470' : Hair.BUZZ_CUT,
			'3467' : Hair.BUZZ_CUT,
			
			'3483' : Hair.GREASER,
			'2633' : Hair.GREASER,
			'3484' : Hair.GREASER,
			'3482' : Hair.GREASER,
			
			'2632' : Hair.CREWCUT,
			'3476' : Hair.CREWCUT,
			'3477' : Hair.CREWCUT,
			'3475' : Hair.CREWCUT,
			
			'3479' : Hair.FADE,
			'3480' : Hair.FADE,
			'3481' : Hair.FADE,
			'3478' : Hair.FADE,
			
			'3472' : Hair.CLEANCUT,
			'3473' : Hair.CLEANCUT,
			'3474' : Hair.CLEANCUT,
			'3471' : Hair.CLEANCUT,
			
			'3490' : Hair.BOB,
			'3491' : Hair.BOB,
			'3492' : Hair.BOB,
			'3489' : Hair.BOB,
			
			'3501' : Hair.PIGTAILS,
			'2977' : Hair.PIGTAILS,
			'3502' : Hair.PIGTAILS,
			'3500' : Hair.PIGTAILS,
			
			'3497' : Hair.FLOWER,
			'3498' : Hair.FLOWER,
			'3499' : Hair.FLOWER,
			'3496' : Hair.FLOWER,
			
			'3504' : Hair.PONY_TAIL,
			'3505' : Hair.PONY_TAIL,
			'3506' : Hair.PONY_TAIL,
			'3503' : Hair.PONY_TAIL,
			
			'3494' : Hair.FLIP,
			'3495' : Hair.FLIP,
			'2634' : Hair.FLIP,
			'3493' : Hair.FLIP,
			
			'2635' : Hair.PONY_TAIL_HEADBAND,
			'3508' : Hair.PONY_TAIL_HEADBAND,
			'3509' : Hair.PONY_TAIL_HEADBAND,
			'3507' : Hair.PONY_TAIL_HEADBAND,
			
			'3511' : Hair.SWIRL,
			'3512' : Hair.SWIRL,
			'3513' : Hair.SWIRL,
			'3510' : Hair.SWIRL
		}
		
		private static function getTypes():Array
		{
			var cleancutTypes:Array = [];
			cleancutTypes[HeadWear.HAT] = HAIR_B;
			cleancutTypes[HeadWear.VISOR] = HAIR_B;
			cleancutTypes[HeadWear.HEADBAND] = HAIR_B;
			cleancutTypes[HeadWear.HELMET] = HAIR_B;
			cleancutTypes[HeadWear.BEANIE] = HAIR_B;
			
			var afroTypes:Array = [];
			afroTypes[HeadWear.HAT] = HAIR_B;
			afroTypes[HeadWear.VISOR] = HAIR_C;
			afroTypes[HeadWear.HEADBAND] = HAIR_D;
			afroTypes[HeadWear.HELMET] = HAIR_E;
			afroTypes[HeadWear.BEANIE] = HAIR_E;
			
			var greaserTypes:Array = [];
			greaserTypes[HeadWear.HAT] = HAIR_B;
			greaserTypes[HeadWear.VISOR] = HAIR_C;
			greaserTypes[HeadWear.HEADBAND] = HAIR_C;
			greaserTypes[HeadWear.HELMET] = HAIR_C;
			greaserTypes[HeadWear.BEANIE] = HAIR_C;
			
			var crewTypes:Array = [];
			crewTypes[HeadWear.HAT] = HAIR_B;
			crewTypes[HeadWear.VISOR] = HAIR_B;
			crewTypes[HeadWear.HEADBAND] = HAIR_B;
			crewTypes[HeadWear.HELMET] = HAIR_B;
			crewTypes[HeadWear.BEANIE] = HAIR_B;
			
			var grungeTypes:Array = [];
			grungeTypes[HeadWear.HAT] = HAIR_B;
			grungeTypes[HeadWear.VISOR] = HAIR_B;
			grungeTypes[HeadWear.HEADBAND] = HAIR_B;
			grungeTypes[HeadWear.HELMET] = HAIR_B;
			grungeTypes[HeadWear.BEANIE] = HAIR_B;
			
			var fadeTypes:Array = [];
			fadeTypes[HeadWear.HAT] = HAIR_B;
			fadeTypes[HeadWear.VISOR] = HAIR_B;
			fadeTypes[HeadWear.HEADBAND] = HAIR_B;
			fadeTypes[HeadWear.HELMET] = HAIR_B;
			fadeTypes[HeadWear.BEANIE] = HAIR_B;
			
			var buzzTypes:Array = [];
			buzzTypes[HeadWear.HAT] = HAIR_B;
			buzzTypes[HeadWear.VISOR] = HAIR_B;
			buzzTypes[HeadWear.HEADBAND] = HAIR_B;
			buzzTypes[HeadWear.HELMET] = HAIR_B;
			buzzTypes[HeadWear.BEANIE] = HAIR_B;
			
			var flipTypes:Array = [];
			flipTypes[HeadWear.HAT] = HAIR_B;
			flipTypes[HeadWear.VISOR] = HAIR_B;
			flipTypes[HeadWear.HEADBAND] = HAIR_B;
			flipTypes[HeadWear.HELMET] = HAIR_C;
			flipTypes[HeadWear.BEANIE] = HAIR_C;
			
			var bobTypes:Array = [];
			bobTypes[HeadWear.HAT] = HAIR_B;
			bobTypes[HeadWear.VISOR] = HAIR_B;
			bobTypes[HeadWear.HEADBAND] = HAIR_B;
			bobTypes[HeadWear.HELMET] = HAIR_B;
			bobTypes[HeadWear.BEANIE] = HAIR_B;
			
			var swirlTypes:Array = [];
			swirlTypes[HeadWear.HAT] = HAIR_B;
			swirlTypes[HeadWear.VISOR] = HAIR_B;
			swirlTypes[HeadWear.HEADBAND] = HAIR_B;
			swirlTypes[HeadWear.HELMET] = HAIR_C;
			swirlTypes[HeadWear.BEANIE] = HAIR_C;
			
			var flowerTypes:Array = [];
			flowerTypes[HeadWear.HAT] = HAIR_B;
			flowerTypes[HeadWear.VISOR] = HAIR_B;
			flowerTypes[HeadWear.HEADBAND] = HAIR_B;
			flowerTypes[HeadWear.HELMET] = HAIR_C;
			flowerTypes[HeadWear.BEANIE] = HAIR_C;
			
			var pigtailTypes:Array = [];
			pigtailTypes[HeadWear.HAT] = HAIR_B;
			pigtailTypes[HeadWear.VISOR] = HAIR_B;
			pigtailTypes[HeadWear.HEADBAND] = HAIR_B;
			pigtailTypes[HeadWear.HELMET] = HAIR_C;
			pigtailTypes[HeadWear.BEANIE] = HAIR_C;
			
			var ponytailHeadbandTypes:Array = [];
			ponytailHeadbandTypes[HeadWear.HAT] = HAIR_B;
			ponytailHeadbandTypes[HeadWear.VISOR] = HAIR_B;
			ponytailHeadbandTypes[HeadWear.HEADBAND] = HAIR_B;
			ponytailHeadbandTypes[HeadWear.HELMET] = HAIR_C;
			ponytailHeadbandTypes[HeadWear.BEANIE] = HAIR_C;
			
			var ponytailTypes:Array = [];
			ponytailTypes[HeadWear.HAT] = HAIR_B;
			ponytailTypes[HeadWear.VISOR] = HAIR_B;
			ponytailTypes[HeadWear.HEADBAND] = HAIR_B;
			ponytailTypes[HeadWear.HELMET] = HAIR_C;
			ponytailTypes[HeadWear.BEANIE] = HAIR_C;
			
			var typesArray:Array = [];
			typesArray[Hair.CLEANCUT] = cleancutTypes;
			typesArray[Hair.AFRO] = afroTypes;
			typesArray[Hair.GREASER] = greaserTypes;
			typesArray[Hair.CREWCUT] = crewTypes;
			typesArray[Hair.GRUNGE] = grungeTypes;
			typesArray[Hair.FADE] = fadeTypes;
			typesArray[Hair.BUZZ_CUT] = buzzTypes;
			typesArray[Hair.FLIP] = flipTypes;
			typesArray[Hair.BOB] = bobTypes;
			typesArray[Hair.SWIRL] = swirlTypes;
			typesArray[Hair.FLOWER] = flowerTypes;
			typesArray[Hair.PIGTAILS] = pigtailTypes;
			typesArray[Hair.PONY_TAIL_HEADBAND] = ponytailHeadbandTypes;
			typesArray[Hair.PONY_TAIL] = ponytailTypes;
			
			return typesArray;
		}
		
		public static function GetHairLayerId(hairTypeId:int, headWearTypeId:int):int
		{
			hairTypeId = (types[hairTypeId] != null) ? types[hairTypeId] : hairTypeId;
			var typesArray:Array = getTypes();
			var hairTypes:Object = (typesArray[hairTypeId] != null) ? typesArray[hairTypeId] : null;
			if (hairTypes == null) return HAIR_A;
			var type:int = (hairTypes[headWearTypeId] != null) ? hairTypes[headWearTypeId] : -1;
			if (type < 0) return HAIR_A;
			
			return type;
		}
		
	}
}
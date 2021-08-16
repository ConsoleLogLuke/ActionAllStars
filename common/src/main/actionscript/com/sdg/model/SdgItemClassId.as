package com.sdg.model
{
	import flash.utils.*;
	
	public class SdgItemClassId
	{
		private static const CLASS_INITIALIZER:Object
		{
			CLASS_ID_MAP[Avatar] = AVATAR;
			CLASS_ID_MAP[InventoryItem] = INVENTORY_ITEM;
			CLASS_ID_MAP[SdgItem] = SDG_ITEM;
		}
		
		public static const AVATAR:uint = 1;
		public static const INVENTORY_ITEM:uint = 2;
		public static const APPAREL_ITEM:uint = 2;
		public static const SDG_ITEM:uint = 3;
		
		private static const CLASS_ID_MAP:Dictionary = new Dictionary();
		
		public static function getIdByClass(itemClass:Class):uint
		{
			var id:uint = CLASS_ID_MAP[itemClass];
			
			if (id == 0)
			{
				var definition:Class = itemClass;
				
				while (id == 0)
				{
					var superName:String = getQualifiedSuperclassName(definition);
					
					if (superName == null)
					{
						throw new ArgumentError("Valid id not found for 'class' " + itemClass + ".");
					}
					
					definition = getDefinitionByName(superName) as Class;
					
					id = CLASS_ID_MAP[definition];
					
					if (id > 0)
					{
						CLASS_ID_MAP[itemClass] = id;
						break;
					}
				}
			}
			
			return id;
		}
		
		public static function getIdByInstance(instance:SdgItem):uint
		{
			return getIdByClass(Object(instance).constructor);
		}
	}
}
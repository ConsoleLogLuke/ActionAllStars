package com.sdg.model
{
	import flash.utils.*;
	
	public class SdgItemUtil
	{
		private static const ITEM_INFO_MAP:Object =
		{
			avatar:{ definition:Avatar, idField:"aId" },
			i:{ definition:InventoryItem, idField:"Id" }
		}
		
		public static function getClassId(object:Object):uint
		{
			if (object is Class) return SdgItemClassId.getIdByClass(Class(object));
			if (object is SdgItem) return SdgItemClassId.getIdByInstance(SdgItem(object));
			
			throw new ArgumentError("Argument 'object' " + object + " must be a Class or instance of SdgItem.");
		}
		
		public static function getInstanceId(instance:SdgItem):uint
		{
			return instance.id;
		}
		
		public static function getInstanceKey(instance:SdgItem):String
		{
			return generateKey(instance, getInstanceId(instance), instance.instanceId);
		}
		
		public static function getXMLClass(xmlName:String, itemTypeId:int):Class
		{
			// Get item info object.
			var itemInfo:Object = getItemInfo(xmlName);
			var classDefinition:Class = itemInfo.definition;
			
			// Determine if we should use a more specific inventory item type.
			if (xmlName == 'i')
			{
				classDefinition = getInventoryItemClass(itemTypeId);
			}
			
			// Return item info definition.
			return classDefinition;
		}
		
		public static function getXMLKey(xml:XML):String
		{
			var info:Object = getItemInfo(xml.name());
			return generateKey(info.definition, xml[info.idField]);
		}
		
		public static function generateKey(object:Object, id:uint, instanceId:int = 0):String
		{
			return getClassId(object) + "_" + id + "_" + instanceId;
		}
		
		private static function getItemInfo(name:String):Object
		{
			var info:Object = ITEM_INFO_MAP[name];
			if (!info) throw new ArgumentError("Definition not found for 'name' " + name + ".");
			return info;
		}
		
		private static function getInventoryItemClass(itemTypeId:int):Class
		{
			switch (itemTypeId)
			{
				case ItemType.PETS:
					return PetItem;
				default:
					return InventoryItem;
			}
		}
	}
}
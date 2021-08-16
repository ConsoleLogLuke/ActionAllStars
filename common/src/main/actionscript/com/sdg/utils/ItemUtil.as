package com.sdg.utils
{
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	
	public class ItemUtil extends Object
	{
		public static function GetInventoryItemFromStoreItem(storeItem:StoreItem, gender:uint = 1):InventoryItem
		{
			var item:InventoryItem = new InventoryItem();
			item.itemId = storeItem.id;
			item.itemTypeId = storeItem.itemTypeId;
			item.name = storeItem.name;
			var contextId:String = (gender == Avatar.MALE) ? "101" : "103";
			item.previewUrl = Environment.getAssetUrl() + "/test/inventoryPreview?itemId=" + item.itemId + "&contextId=" + contextId;
			item.previewUrlAlt = Environment.getAssetUrl() + "/test/inventoryPreview?itemId=" + item.itemId + "&contextId=" + contextId + "&layerId=9010";
			//item.thumbnailUrl = Environment.getAssetUrl() + "/test/inventoryThumbnail?itemId=" + item.itemId;
			item.thumbnailUrl = GetSmallThumbnailUrl(item.itemId);
			item.itemSetId = storeItem.itemSetId;
			
			return item;
		}
		
		public static function GetSmallThumbnailUrl(itemId:uint):String
		{
			var prefix:String = (Constants.SWF_SPRITES_ENABLED == true) ? 'spriteswf' : 'spritesheet';
			return Environment.getAssetUrl() + '/test/static/' + prefix + '?itemId=' + itemId + '&layerId=9520';
		}
		
		public static function GetLargeThumbnailUrl(itemId:uint):String
		{
			var prefix:String = (Constants.SWF_SPRITES_ENABLED == true) ? 'spriteswf' : 'spritesheet';
			return Environment.getAssetUrl() + '/test/static/' + prefix + '?itemId=' + itemId + '&layerId=9510';
		}
		
		public static function GetPreviewUrl(itemId:uint, isMale:Boolean = true, layerId:uint = 9000):String
		{
			var contextId:uint = (isMale == true) ? 101 : 103;
			var prefix:String = (Constants.SWF_SPRITES_ENABLED == true) ? 'spriteswf' : 'spritesheet';
			return Environment.getAssetUrl() + '/test/static/' + prefix + '?itemId=' + itemId + '&layerId=' + layerId + '&contextId=' + contextId;
		}
		
		public static function GetHeadwearHairPreviewUrl(hairItemId:uint, headwearItemTypeId:uint, isMale:Boolean = true):String
		{
			// Determine hat hair layer id.
			var layerId:int = HairUtil.GetHairLayerId(hairItemId, headwearItemTypeId);
			var contextId:uint = (isMale == true) ? 101 : 103;
			var prefix:String = (Constants.SWF_SPRITES_ENABLED == true) ? 'spriteswf' : 'spritesheet';
			return Environment.getAssetUrl() + '/test/static/' + prefix + '?itemId=' + hairItemId + '&layerId=' + layerId + '&contextId=' + contextId;
		}
		
		public static function GetItemAttributesUrl(itemId:uint, avatarId:uint = 4):String
		{
			return Environment.getApplicationUrl() + '/test/dyn/item/get?itemId=' + itemId + '&avatarId=' + avatarId;
		}
		
	}
}
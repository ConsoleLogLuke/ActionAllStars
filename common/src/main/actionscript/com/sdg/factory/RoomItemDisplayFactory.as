package com.sdg.factory
{
	import com.sdg.business.resource.*;
	import com.sdg.display.*;
	import com.sdg.display.gamelaunch.GameLaunchPointDisplay;
	import com.sdg.display.leaderboard.InWorldLeaderboardDisplay;
	import com.sdg.display.leaderboard.InWorldLeaderboardFlicker;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.SdgItem;
	import com.sdg.model.SdgItemAssetType;

	public class RoomItemDisplayFactory
	{
		// private static const CLASS_INITIALIZER:Object // Non-SDG - this is completely unnecessary
		{
			ASSET_TYPE_CLASS_MAP[SdgItemAssetType.SPRITESHEET] = RoomItemSprite;
			ASSET_TYPE_CLASS_MAP[SdgItemAssetType.SPRITESHEET_2] = RoomItemSprite;
			ASSET_TYPE_CLASS_MAP[SdgItemAssetType.SWF] = RoomItemSWF;
			ASSET_TYPE_CLASS_MAP[SdgItemAssetType.BACKGROUND_CHILD] = EmbeddedRoomItemDisplay;
			ASSET_TYPE_CLASS_MAP[SdgItemAssetType.GAME_LAUNCH_POINT] = GameLaunchPointDisplay;
			ASSET_TYPE_CLASS_MAP[SdgItemAssetType.IN_WORLD_LEADERBOARD] = InWorldLeaderboardDisplay;
			ASSET_TYPE_CLASS_MAP[SdgItemAssetType.IN_WORLD_LEADERBOARD_FLICKER] = InWorldLeaderboardFlicker;
		}

		private static const ASSET_TYPE_CLASS_MAP:Object = {};

		protected var item:SdgItem;

		public function setItem(item:SdgItem):void
		{
			this.item = item;
		}

		public function createInstance():Object
		{
			var display:IRoomItemDisplay;

			// Determine a display class.
			// If item is an Avatar, create an instance of AvatarSprite.
			if (item is Avatar)
			{
				displayClass = AvatarSprite;
			}
			else
			{
				// Otherwise, determine a display class for this item.
				var displayClass:Class = ASSET_TYPE_CLASS_MAP[item.assetType];
			}

			display = new displayClass(item);
			display.mouseEnabled = (item is InventoryItem) ? InventoryItem(item).itemTypeId != 12 : true;
			display.orientation = item.orientation;

			return display;
		}
	}
}

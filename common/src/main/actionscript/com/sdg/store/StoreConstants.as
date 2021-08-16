// ActionScript file
package com.sdg.store
{
	import com.sdg.utils.Constants;
	import com.sdg.logging.LoggingUtil;
	
	
	public final class StoreConstants
	{
		public static const STORE_ID_RIVERWALK:int = 2209;
		public static const STORE_ID_VERTVILLAGE:int = 2208;
		public static const STORE_ID_NBA:int = 2061;
		public static const STORE_ID_MLB:int = 2095;
		public static const STORE_ID_NFL:int = 2335;
		public static const STORE_ID_PET:int = 2360;
		public static const STORE_ID_CATALOG:int = 10000;
		public static const STORE_ID_TOPTEN:int = 10001;
		public static const STORE_ID_GAMEVENDOR:int = 10002;
		public static const STORE_ID_RBI:int = 10003;
		public static const STORE_ID_INWOLRDSHOPDIALOG:int = 10004;
		
		public static const ITEM_CLASS_CLOTHING:int=1;
		public static const ITEM_CLASS_FURNITURE:int=2;
		
		// Make a map of these if we get any more.
		public static function getLoggingViewIdForStore(storeId:int):int
		{
			if(storeId == STORE_ID_PET)
			{
				return LoggingUtil.MVP_UPSELL_VIEW_PET_STORE;
			}
			return LoggingUtil.MVP_UPSELL_VIEW_STORE;
		}
		public static function getLoggingClickIdForStore(storeId:int):int
		{
			if(storeId == STORE_ID_PET)
			{
				return LoggingUtil.MVP_UPSELL_CLICK_PET_STORE;
			}
			return LoggingUtil.MVP_UPSELL_CLICK_STORE;
		}
		
		public static function getStoreFromGameId(gameId:int):int
		{
			if ((gameId == Constants.HOOPS_GAME_ID) || (gameId == Constants.HANDLES_GAME_ID) ||
				(gameId == Constants.THREE_GAME_ID) || (gameId == Constants.BITES_GAME_ID))
			{
				return StoreConstants.STORE_ID_NBA;
			}
			else if ((gameId == Constants.BUMPER_BASEBALL_GAME_ID) || (gameId == Constants.PITCHING_ACE_GAME_ID))
			{
				return StoreConstants.STORE_ID_MLB;
			}
			else if ((gameId == Constants.SNOWBOARDING_GAME_ID) || (gameId == Constants.SURFING_GAME_ID))
			{
				return StoreConstants.STORE_ID_VERTVILLAGE;
			}
			else
			{
				return StoreConstants.STORE_ID_RIVERWALK;
			}
		}
	}
}
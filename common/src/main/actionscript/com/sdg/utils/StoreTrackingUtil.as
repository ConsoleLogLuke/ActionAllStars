package com.sdg.utils
{
	import com.sdg.net.socket.SocketClient;
	import com.sdg.store.StoreConstants;
	
	public class StoreTrackingUtil
	{
		public static const PDA_CATALOG:int = 1;
		public static const CATALOG_AAS_STORE:int = 2;
		public static const CATALOG_MLB_STORE:int = 3;
		public static const CATALOG_NBA_STORE:int = 4;
		public static const ROOM_AAS_STORE:int = 5;
		public static const ROOM_VERT_STORE:int = 6;
		public static const ROOM_MLB_STORE:int = 7;
		public static const ROOM_NBA_STORE:int = 8;
		
		private static const PAGE_ID_LINK_ID_MAP:Object =
		{
			1:{pageId:17, linkId: 57},
			2:{pageId:18, linkId: 58},
			3:{pageId:18, linkId: 59},
			4:{pageId:18, linkId: 60},
			5:{pageId:19, linkId: 61},
			6:{pageId:20, linkId: 62},
			7:{pageId:21, linkId: 63},
			8:{pageId:22, linkId: 64}
		}
		
		public static function trackButtonClick(type:int):void
		{
			var btnClkObject:Object = PAGE_ID_LINK_ID_MAP[type];
			var btnClkString:String = btnClkObject.pageId + ";" + btnClkObject.linkId;
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "btnClk", { btnClk:btnClkString });
		}
		
		public static function trackCatalogStoreClick(storeId:int, fromCatalog:Boolean = false):void
		{
			if (fromCatalog)
			{
				switch (storeId)
				{
					case StoreConstants.STORE_ID_RIVERWALK:
						trackButtonClick(CATALOG_AAS_STORE);
						break;
					case StoreConstants.STORE_ID_MLB:
						trackButtonClick(CATALOG_MLB_STORE);
						break;
					case StoreConstants.STORE_ID_NBA:
						trackButtonClick(CATALOG_NBA_STORE);
						break;
				}
			}
			else
			{
				switch (storeId)
				{
					case StoreConstants.STORE_ID_RIVERWALK:
						trackButtonClick(ROOM_AAS_STORE);
						break;
					case StoreConstants.STORE_ID_VERTVILLAGE:
						trackButtonClick(ROOM_VERT_STORE);
						break;
					case StoreConstants.STORE_ID_MLB:
						trackButtonClick(ROOM_MLB_STORE);
						break;
					case StoreConstants.STORE_ID_NBA:
						trackButtonClick(ROOM_NBA_STORE);
						break;
				}
			}
		}
	}
}
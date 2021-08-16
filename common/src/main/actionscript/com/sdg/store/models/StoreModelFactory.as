package com.sdg.store.models
{
	import com.sdg.store.StoreModel;
	import com.sdg.store.StoreConstants;
	
	public class StoreModelFactory
	{
		public static function createStoreModel(storeId:uint):StoreModel
		{
			if(storeId == StoreConstants.STORE_ID_PET)
			{
				return new StoreNoNavModel(storeId);
			}
			return new StoreModel(storeId);
		}
	}
}
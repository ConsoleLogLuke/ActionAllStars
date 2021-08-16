package com.sdg.printshop.printitem
{
	public class PrintItemMapping
	{
		// 6046 is not in Item Database
		public static const itemIdMapping:Object = {6043:MyCardFrontPrintItem,6044:MyCardBackPrintItem,
													6045:FoldableMyCardPrintItem, 6046:ReferAFriendPrintableItem};
		
		public function PrintItemMapping()
		{
		}
		
		public static function getItemFromItemId(id:String):Class
		{
			return itemIdMapping[id];
		}

	}
}
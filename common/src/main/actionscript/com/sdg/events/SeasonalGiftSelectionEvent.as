package com.sdg.events
{
 	import com.adobe.cairngorm.control.CairngormEvent;

	public class SeasonalGiftSelectionEvent extends CairngormEvent
	{
		public static const SEASONAL_GIFT_SELECTION:String = "seasonalGiftSelection";
 	
		private var _avatarId:uint;
		private var _itemId:uint;
		private var _answerId:String;
		private var _additionalComments:String;
		private var _result:String;

		public function SeasonalGiftSelectionEvent( avatarId:uint, itemId:uint, answerId:String, additionalComments:String)
		{
			super(SEASONAL_GIFT_SELECTION);
 			
			_avatarId = avatarId;
			_itemId = itemId;
			_answerId = answerId;
			_additionalComments = additionalComments;
		}

		public function get avatarId():int
		{
			return _avatarId;
		}

		public function get itemId():int
		{
			return _itemId;
		}
 		
		public function get answerId():String
		{
			return _answerId;
		}
		public function get additionalComments():String
		{
			return _additionalComments;
		}
 		
 		public function get result():String
 		{
 			return _result;
 		}

	}
}


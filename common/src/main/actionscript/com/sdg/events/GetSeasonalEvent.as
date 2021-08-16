package com.sdg.events
{
 	import com.adobe.cairngorm.control.CairngormEvent;
 
 	public class GetSeasonalEvent extends CairngormEvent
 	{
 		public static const GET_SEASONAL:String = "getSeasonal";
 		public static const GET_SEASONAL_COMPLETED:String = "getSeasonalCompleted";
 		
		private var _avatarId:uint;
		private var _xml:XML;
		
 		public function GetSeasonalEvent(avatarId:uint, type:String = GET_SEASONAL, xml:XML = null)
 		{
 			super(type);
			_avatarId = avatarId;
			_xml = xml;
 		}

		public function get avatarId():int
		{
			return _avatarId;
		}

		public function get seasonalXml():XML
		{
			return _xml;
		}
 	}
}

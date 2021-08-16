package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class TickerEvent extends CairngormEvent
	{
		public static const GET_FEED:String = "getFeed";
		public static const FEED_RECEIVED:String = "feedReceived";
		public static const INFO_REQUESTED:String = "infoRequested";
		public static const INFO_RECEIVED:String = "infoReceived";
		public static const NEEDS_REFRESH:String = "needsRefresh";
		
		private var _eventType:String;
		private var _xmlData:XML;
		
		public function TickerEvent(eventType:String = GET_FEED, xmlData:XML = null)
		{
			super(eventType);
			_eventType = eventType;
			_xmlData = xmlData;
		}

		public function get eventType():String
		{
			return _eventType;
		}
		
		public function get xmlData():XML
		{
			return _xmlData;
		}
	}
}
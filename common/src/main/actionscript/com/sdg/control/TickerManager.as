package com.sdg.control
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.events.TickerEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class TickerManager
	{
		private static var _instance:TickerManager;
		private var _tickerFeed:XML = null;
		private var refreshTickerClock:Timer = new Timer(3600000, 0);
		
		public function TickerManager()
		{
			if (_instance)
				throw new Error("TickerManager is a singleton class. Use 'getInstance()' to access the instance.");
			else
				refreshTickerClock.addEventListener(TimerEvent.TIMER, onNeedsRefresh);
		}
		
		public static function getInstance():TickerManager
		{
			if (_instance == null) _instance = new TickerManager();
			return _instance;
		}
		
		public function requestFeed():void
		{
			if (_tickerFeed == null)
			{
				CairngormEventDispatcher.getInstance().addEventListener(TickerEvent.FEED_RECEIVED, onFeedReceived);
				CairngormEventDispatcher.getInstance().dispatchEvent(new TickerEvent());
			}
			else
				returnTickerInfo();
		}
		
		private function onFeedReceived(ev:TickerEvent):void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(TickerEvent.FEED_RECEIVED, onFeedReceived);
			_tickerFeed = ev.xmlData;
			refreshTickerClock.start();
			returnTickerInfo();
		}
		
		private function onNeedsRefresh(ev:TimerEvent):void
		{
			refreshTickerClock.stop();
			_tickerFeed = null;
			CairngormEventDispatcher.getInstance().dispatchEvent(new TickerEvent(TickerEvent.NEEDS_REFRESH));
		}
		
		private function returnTickerInfo():void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new TickerEvent(TickerEvent.INFO_RECEIVED, _tickerFeed));
		}
	}
}
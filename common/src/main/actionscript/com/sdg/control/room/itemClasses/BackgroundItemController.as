package com.sdg.control.room.itemClasses
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.control.TickerManager;
	import com.sdg.display.RoomItemSWF;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.events.SdgSwfEvent;
	import com.sdg.events.TickerEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.Environment;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class BackgroundItemController extends RoomItemController
	{
		protected var _content:*;
		
		public function BackgroundItemController()
		{
			super();
		}
		
		
		/*
		 * CLASS METHODS
		*/
		override protected function addDisplayListeners():void
		{
			super.addDisplayListeners();
			
			// check if content of the swf is available
			var d:RoomItemSWF = RoomItemSWF(display);
			d.mouseChildren = false;
			
			// End debug
			if (d.content)
			{
				addListeners();
			}
			else
			{
				d.addEventListener(RoomItemDisplayEvent.CONTENT, contentReady);
			}
			
			function contentReady(e:Event):void
			{
				d.removeEventListener(RoomItemDisplayEvent.CONTENT, contentReady);
				addListeners();
			}
			
			function addListeners():void
			{
				_content = d.content;
				
				try
				{
					_content.addEventListener(SdgSwfEvent.SDG_SWF_EVENT, swfEventHandler);
					_content.init();
				}
				catch (e:Error)
				{
					// handle error
					trace("ERROR: " + e.getStackTrace());
				}
			}
		}
		
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			super.mouseClickHandler(event);
			LoggingUtil.sendClickLogging(3023);
		}
		
		override public function destroy():void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(TickerEvent.INFO_RECEIVED, onInfoReceived);
			CairngormEventDispatcher.getInstance().removeEventListener(TickerEvent.NEEDS_REFRESH, onNeedsRefresh);
			
			_content.destroy();
			
			super.destroy();
		}
		
		// Event handlers
		protected function swfEventHandler(e:Event):void
		{
			_content.removeEventListener(SdgSwfEvent.SDG_SWF_EVENT, swfEventHandler);
			var eventType:String = Object(e).data.eventType;
			
			if (eventType == "ticker")
			{
				CairngormEventDispatcher.getInstance().addEventListener(TickerEvent.INFO_RECEIVED, onInfoReceived);
				CairngormEventDispatcher.getInstance().addEventListener(TickerEvent.NEEDS_REFRESH, onNeedsRefresh);
				TickerManager.getInstance().requestFeed();
			}
		}
		
		private function onInfoReceived(e:TickerEvent):void
		{
			//CairngormEventDispatcher.getInstance().removeEventListener(TickerEvent.INFO_RECEIVED, onInfoReceived);
			_content.tickerInfo = {xmlData:e.xmlData, appDomain:Environment.getApplicationDomain()}; 
		}
		
		private function onNeedsRefresh(e:TickerEvent):void
		{
			TickerManager.getInstance().requestFeed();
		}
		
	}
}
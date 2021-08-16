package com.sdg.components.controls
{
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class CustomAlert extends Canvas
	{
		private var _alert:Image;
		private var _eventIdentifierMap:Object;
		
		public function CustomAlert()
		{
			super();
		}
		
		/**
		 * Static show method.
		 */
		public static function show(url:String, closeHandler:Function = null, eventIdentifierMap:Object = null):CustomAlert
		{
			var alert:CustomAlert = new CustomAlert();
			alert.show(url, closeHandler, eventIdentifierMap);
			return alert;
		}
		
		public function show(url:String, closeHandler:Function = null, eventIdentifierMap:Object = null):void
		{
			_alert = new Image();
			_alert.addEventListener(Event.INIT, onInit);
			_alert.source = url;
			addChild(_alert);
			
			function onInit(event:Event):void
			{
				_alert.removeEventListener(Event.INIT, onInit);
				
				_eventIdentifierMap = eventIdentifierMap;
				if (closeHandler != null)
					addEventListener(CloseEvent.CLOSE, closeHandler);
				
				addEventListeners();
				
				width = _alert.contentWidth;
				height = _alert.contentHeight;
				
				showDialog();
			}
		}
		
		private function showDialog():void
		{
			MainUtil.showModalDialog(null, null, this);
		}
		
		private function addEventListeners():void
		{
			var content:DisplayObject = _alert.content;
			for (var eventType:String in _eventIdentifierMap)
				content.addEventListener(eventType, eventHandler);
		}
		
		private function removeEventListeners():void
		{
			var content:DisplayObject = _alert.content;
			for (var eventType:String in _eventIdentifierMap)
				content.removeEventListener(eventType, eventHandler);
		}
		
		private function eventHandler(event:Event):void
		{
			var identifier:Object;
			if (_eventIdentifierMap != null)
				identifier = _eventIdentifierMap[event.type];
			
			close(identifier == null ? -1 : int(identifier));
		}
		
		private function close(closeDetail:int = -1):void
		{
			removeEventListeners();
			
			var event:CloseEvent = new CloseEvent(CloseEvent.CLOSE, false, true, closeDetail);
			
			dispatchEvent(event);
			
			if (!event.isDefaultPrevented())
			{
				visible = false;
				PopUpManager.removePopUp(this);
			}
		}
	}
}
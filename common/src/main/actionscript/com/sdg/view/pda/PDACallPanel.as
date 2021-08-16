package com.sdg.view.pda
{
	import com.sdg.control.PDAController;
	import com.sdg.model.PDACallModel;
	import com.sdg.view.pda.interfaces.IPDAMainPanel;
	import com.sdg.view.pda.interfaces.IPDASidePanel;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class PDACallPanel extends Sprite implements IPDAMainPanel
	{
		private var _callData:PDACallModel;
		private var _width:Number;
		private var _height:Number;
		private var _callerImageLoader:Loader;
		private var _callerImage:DisplayObject;
		private var _callerImageMask:Sprite;
		private var _isInitialized:Boolean = false;
		
		public function PDACallPanel(callData:PDACallModel)
		{
			super();
			
			_callData = callData;
			
			// Set default values.
			_width = 300;
			_height = 400;
			
			// Create caller image mask.
			_callerImageMask = new Sprite();
			addChild(_callerImageMask);
			
			// Load caller image.
			var url:String = callData.callerImageUrl;
			if (url.length > 0)
			{
				var request:URLRequest = new URLRequest(url);
				_callerImageLoader = new Loader();
				_callerImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCallerImageComplete);
				_callerImageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onCallerImageError);
				_callerImageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onCallerImageProgress);
				_callerImageLoader.load(request);
			}
		}
		
		public function init(controller:PDAController = null):void
		{
		}
		
		public function close():void
		{
			// Remove event listeners.
		}
		
		public function refresh():void
		{
		}
		
		public function render():void
		{
			// Position visual elements.
			if (_callerImage != null)
			{
				// Fit the caller image proportionately into the panel.
				var scale:Number = Math.max(_width / _callerImage.width, _height / _callerImage.height);
				_callerImage.width *= scale;
				_callerImage.height *= scale;
				_callerImage.x = _width / 2 - _callerImage.width / 2;
				_callerImage.y = _height / 2 - _callerImage.height / 2;
			}
			
			// Draw caller image mask.
			_callerImageMask.graphics.clear();
			_callerImageMask.graphics.beginFill(0xffffff);
			_callerImageMask.graphics.drawRect(0, 0, _width, _height);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set controller(value:PDAController):void
		{
		}
		
		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}
			
		public function set isInitialized(value:Boolean):void
		{
			_isInitialized = value;
		}
		
		public function get sidePanel():IPDASidePanel
		{
			return null;
		}
		
		public function get panelName():String
		{
			return _callData.callerName;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onCallerImageComplete(e:Event):void
		{
			// Finished loading caller image.
			
			// Remove listeners.
			_callerImageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCallerImageComplete);
			_callerImageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onCallerImageError);
			_callerImageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onCallerImageProgress);
			
			// Add the image to the display.
			_callerImage = _callerImageLoader.content;
			_callerImage.mask = _callerImageMask;
			addChild(_callerImage);
			render();
		}
		
		private function onCallerImageError(e:IOErrorEvent):void
		{
			// There was an error loading the caller image.
			
			// Remove listeners.
			_callerImageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCallerImageComplete);
			_callerImageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onCallerImageError);
			_callerImageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onCallerImageProgress);
		}
		
		private function onCallerImageProgress(e:ProgressEvent):void
		{
			
		}
		
	}
}
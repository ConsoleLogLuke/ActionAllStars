package com.sdg.view
{
	import com.good.goodui.FluidView;
	import com.sdg.model.IInitable;
	import com.sdg.util.AssetUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class UserTitleBackground extends FluidView implements IInitable
	{
		protected var _content:DisplayObject;
		protected var _level:uint;
		protected var _color1:uint;
		protected var _color2:uint;
		protected var _contentLoader:Loader;
		protected var _progressLayer:Sprite;
		protected var _mask:Sprite;
		protected var _isInit:Boolean;
		protected var _isLoading:Boolean;
		
		public function UserTitleBackground(width:Number, height:Number, level:uint, color1:uint, color2:uint, autoInit:Boolean = true)
		{
			super(width, height);
			
			_color1 = color1;
			_color2 = color2;
			_level = level;
			_isInit = false;
			_isLoading = false;
			
			_mask = new Sprite();
			
			// Draw a placeholder for now.
			var c:Sprite = new Sprite();
			c.graphics.beginFill(0xffffff, 0);
			c.graphics.drawRect(0, 0, width, height);
			
			_content = c;
			_content.mask = _mask;
			
			_progressLayer = new Sprite();
			
			addChild(_progressLayer);
			addChild(_content);
			addChild(_mask);
			
			render();
			
			if (autoInit == true) init();
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			loadContent();
		}
		
		public function destroy():void
		{
			// Remove displays.
			removeChild(_content);
			removeChild(_mask);
			
			// Destroy references to help garbage collection.
			_content = null;
			_mask = null;
			_progressLayer = null;
		}
		
		public function setParams(level:uint, color1:uint, color2:uint):void
		{
			_level = level;
			_color1 = color1;
			_color2 = color2;
			
			loadContent();
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawRect(0, 0, _width, _height);
			
			_content.width = _width;
			_content.height = _height;
		}
		
		protected function loadContent():void
		{
			// Unload loader if necesary.
			if (_isLoading == true)
			{
				_contentLoader.unload();
				_isLoading = false;
				
				// Remove event listeners.
				_contentLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				_contentLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				_contentLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
			
			// Load the asset.
			var url:String = AssetUtil.GetGameAssetUrl(99, 'user_title_bg_0' + _level + '.swf');
			var request:URLRequest = new URLRequest(url);
			_contentLoader = new Loader();
			_contentLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_contentLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_isLoading = true;
			_contentLoader.load(request);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get level():uint
		{
			return _level;
		}
		
		public function get color1():uint
		{
			return _color1;
		}
		
		public function get color2():uint
		{
			return _color2;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onError(e:IOErrorEvent):void
		{
			// Remove event listeners.
			_contentLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_contentLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_contentLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			_isLoading = false;
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			_progressLayer.graphics.clear();
			_progressLayer.graphics.beginFill(0xffffff);
			_progressLayer.graphics.drawRect(0, 0, _width * (e.bytesLoaded / e.bytesTotal), _height);
		}
		
		private function onComplete(e:Event):void
		{
			// Remove event listeners.
			_contentLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_contentLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_contentLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			_isLoading = false;
			
			// Remove progress layer.
			removeChild(_progressLayer);
			
			// Remove previous content.
			removeChild(_content);
			
			// Set new content.
			_content = _contentLoader.content;
			_content.mask = _mask;
			var c:Object = Object(_content);
			c.color1 = _color1;
			c.color2 = _color2;
			addChild(_content);
			
			render();
		}
		
	}
}
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
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;

	public class TeamIcon extends FluidView implements IInitable
	{
		protected var _teamId:uint;
		protected var _color1:uint;
		protected var _color2:uint;
		protected var _back:Sprite;
		protected var _mask:Sprite;
		protected var _line:Sprite;
		protected var _isInit:Boolean;
		protected var _loader:Loader;
		protected var _isLoading:Boolean;
		protected var _logo:Sprite;
		protected static var _glow:GlowFilter;
		protected var _isDestroy:Boolean;
		
		public function TeamIcon(width:Number, height:Number, teamId:uint, color1:uint, color2:uint, autoInit:Boolean = true)
		{
			_teamId = teamId;
			_color1 = color1;
			_color2 = color2;
			_isInit = false;
			_isLoading = false;
			_glow = new GlowFilter(0xffffff, 1, 2, 2, 10);
			_isDestroy = false;
			
			_mask = new Sprite();
			
			_back = new Sprite();
			_back.mask = _mask;
			
			_line = new Sprite();
			
			addChild(_back);
			addChild(_mask);
			addChild(_line);
			
			super(width, height);
			
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
			
			loadLogo();
		}
		
		public function destroy():void
		{
			if (_isDestroy == true) return;
			_isDestroy = true;
			
			// Remove displays.
			removeChild(_back);
			removeChild(_mask);
			removeChild(_line);
			
			// Destroy references to help garbage collection.
			_back = null;
			_mask = null;
			_line = null;
			_glow = null;
		}
		
		public function setParams(teamId:uint, color1:uint, color2:uint):void
		{
			_teamId = teamId;
			_color1 = color1;
			_color2 = color2;
			
			loadLogo();
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			if (_isDestroy == true) return;
			
			super.render();
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawRoundRect(0, 0, _width, _height, 10, 10);
			
			_back.graphics.clear();
			_back.graphics.beginFill(_color1);
			_back.graphics.drawRect(0, 0, _width, _height);
			
			_line.graphics.clear();
			_line.graphics.lineStyle(2, _color2);
			_line.graphics.drawRoundRect(0, 0, _width, _height, 10, 10);
		}
		
		protected function loadLogo(url:String = null):void
		{
			// Stop current loading.
			if (_isLoading == true)
			{
				_loader.unload();
				
				// Remove event listeners.
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			}
			
			// Set flag.
			_isLoading = true;
			
			if (url == null)
			{
				// Load team logo.
				url = AssetUtil.GetTeamLogoUrl(_teamId);
			}
			
			var request:URLRequest = new URLRequest(url);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(request);
		}
		
		protected function placeLogo():void
		{
			if (_isDestroy == true) return;
			// Remove previous logo.
			if (_logo != null) _back.removeChild(_logo);
			
			_logo = new Sprite();
			var logo:DisplayObject = _loader.content;
			var maxW:Number = _width * 1.2;
			var maxH:Number = _height * 1.2;
			var scale:Number = Math.max(maxW / logo.width, maxH / logo.height);
			logo.width *= scale;
			logo.height *= scale;
			logo.x = - logo.width / 2;
			logo.y = - logo.height / 2;
			_logo.addChild(logo);
			_logo.x = _width / 2;
			_logo.y = _height / 2;
			_logo.rotation = -10;
			if (_glow) _logo.filters = [_glow];
			_back.addChild(_logo);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onError(e:IOErrorEvent):void
		{
			// Remove event listeners.
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			
			// Set flag.
			_isLoading = false;
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			_back.graphics.clear();
			_back.graphics.beginFill(_color1);
			_back.graphics.drawRect(0, 0, _width, _height * (e.bytesLoaded / e.bytesTotal));
		}
		
		private function onComplete(e:Event):void
		{
			// Remove event listeners.
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			
			placeLogo();
			render();
			
			// Set flag.
			_isLoading = false;
		}
		
	}
}
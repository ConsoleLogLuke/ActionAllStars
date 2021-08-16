package com.sdg.net
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	
	import mx.modules.ModuleLoader;

	public class SdgModuleLoader extends ModuleLoader
	{
		private static var _instance:SdgModuleLoader;
		private static var standin:DisplayObject;
		private static var _id:Sprite;
		
		public static function getInstance():SdgModuleLoader
		{
			if (!_instance)
			{
				_instance = new SdgModuleLoader();
				_instance.init();
			}

			return _instance;
		}
		public function setTarget(id:Sprite):void
		{
			_id = id;
		}
		public function load(src:String):void
		{
			_instance.url = src;
			_instance.loadModule();
		}
		
		public function init():void 
		{
			addEventListener("urlChanged", onUrlChanged);
			addEventListener("loading", onLoading);
			addEventListener("progress", onProgress);
			addEventListener("setup", onSetup);
			addEventListener("ready", onReady);
			addEventListener("error", onError);
			addEventListener("unload", onUnload);
			//standin = mainWindow;
			//removeChild(standin);
		}
		public function onUrlChanged(event:Event):void 
		{
			trace(event.type);
			//return;
			/*
			if (url == null) {
				if (contains(standin))
				{
					_id.removeChild(standin);
				} else {
					if (!contains(standin))
					{
						_id.addChild(standin);
					}
				}
			}
			*/
		}

		public function onLoading(event:Event):void 
		{
			/*
			if (!contains(standin))
			{
				addChild(standin);
			}
			*/
		}
		public function onProgress(event:Event):void 
		{

		}
		public function onSetup(event:Event):void 
		{

		}
		public function onReady(event:Event):void {
			/*
			if (contains(standin))
			{
				removeChild(standin);
			}
			*/
			trace(event.type);
		}
		public function onError(event:Event):void 
		{
		}
		public function onUnload(event:Event):void 
		{
			/*
			if (url == null) {
				if (contains(standin))
				{
					removeChild(standin);
				} else {
					if (!contains(standin))
					{
						addChild(standin);
					}
				}
			}
			*/
		}
		
	}
}
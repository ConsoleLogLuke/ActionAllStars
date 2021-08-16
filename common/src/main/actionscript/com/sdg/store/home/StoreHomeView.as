package com.sdg.store.home
{
	import com.sdg.mvc.ViewBase;
	import com.sdg.net.QuickLoader;
	
	import flash.display.Sprite;

	public class StoreHomeView extends ViewBase implements IStoreHomeView
	{
		protected var _url:String;
		protected var _remoteAsset:Sprite;
		
		public function StoreHomeView()
		{
			super();
		}
		
		override public function render():void
		{
			super.render();
		}
		
		public function set url(value:String):void
		{
			if (value == _url) return;
			_url = value;
			
			// Remove the previous remote asset.
			if (_remoteAsset != null)
			{
				removeChild(_remoteAsset);
			}
			
			// Load the new remote asset.
			_remoteAsset = new QuickLoader(_url, render);
			addChild(_remoteAsset);
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if (_remoteAsset == null) return;
			_remoteAsset.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if (_remoteAsset == null) return;
			_remoteAsset.removeEventListener(type, listener, useCapture);
		}
		
	}
}
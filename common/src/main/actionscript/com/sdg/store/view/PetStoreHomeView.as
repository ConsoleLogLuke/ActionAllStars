package com.sdg.store.view
{
	import com.sdg.net.QuickLoader;
	import com.sdg.store.home.StoreHomeView;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class PetStoreHomeView extends StoreHomeView
	{
		public function PetStoreHomeView()
		{
			super();
		}
		
		public override function set url(value:String):void
		{
			if (value == _url) return;
			_url = value;
			
			// Remove the previous remote asset.
			if (_remoteAsset != null)
			{
				removeChild(_remoteAsset);
			}
			
			// Load the new remote asset.
			_remoteAsset = new QuickLoader(_url, onLoadComplete);
			addChild(_remoteAsset);
		}
		
		protected function onLoadComplete():void
		{
			render();
			getContent().dispatchEvent(new Event('viewLoaded'));
		}
		
		public function getContent():DisplayObject
		{
			if(_remoteAsset != null)
			{
				return (_remoteAsset as QuickLoader).content;
			}
			return null;
		}
		
	}
}
package com.sdg.store.preview
{
	import flash.events.IEventDispatcher;
	
	public interface IStoreAvatarPreviewController extends IEventDispatcher
	{
		function init(model:IStoreAvatarPreviewModel):void;
		function destroy():void;
	}
}
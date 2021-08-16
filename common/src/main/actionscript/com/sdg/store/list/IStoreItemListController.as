package com.sdg.store.list
{
	import flash.events.IEventDispatcher;
	
	public interface IStoreItemListController extends IEventDispatcher
	{
		function init(model:IStoreItemListModel):void;
		function destroy():void;
	}
}
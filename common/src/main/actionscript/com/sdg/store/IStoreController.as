package com.sdg.store
{
	import flash.events.IEventDispatcher;
	
	public interface IStoreController extends IEventDispatcher
	{
		function init(model:IStoreModel):void;
	}
}
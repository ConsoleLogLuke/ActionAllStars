package com.sdg.store.nav
{
	import flash.events.IEventDispatcher;
	
	public interface IStoreNavController extends IEventDispatcher
	{
		function init(model:IStoreNavModel):void;
	}
}
package com.sdg.store.catalog
{
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.mvc.IView;
	
	import flash.display.DisplayObject;

	public interface IStoreCatalogFeaturedPanel extends IView
	{
		function set background(value:DisplayObject):void;
		function set featuredDisplaySet(value:DisplayObjectCollection):void;
	}
}
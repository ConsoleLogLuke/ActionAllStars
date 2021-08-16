package com.sdg.store.catalog
{
	import com.sdg.model.StoreItemCollection;
	import com.sdg.mvc.IView;
	
	import flash.display.DisplayObject;

	public interface IStoreCatalogItemListView extends IView
	{
		function setMargin(top:Number, right:Number, bottom:Number, left:Number):void;
		
		function set items(value:StoreItemCollection):void;
		function set background(value:DisplayObject):void;
	}
}
package com.sdg.store.list
{
	import com.sdg.mvc.IView;
	import com.sdg.store.item.IStoreItemView;
	import com.sdg.store.item.StoreItemViewCollection;
	
	import flash.display.DisplayObject;
	
	public interface IStoreItemListView extends IView
	{
		function init(width:Number, height:Number):void;
		function showDetailView(itemView:IStoreItemView):void;
		
		function set background(value:DisplayObject):void;
		function set windowBackground(value:DisplayObject):void;
		function set itemViews(value:StoreItemViewCollection):void;
		function set itemSetName(value:String):void;
		function set itemSetImage(value:DisplayObject):void;
		function set sortType(value:String):void;
	}
}
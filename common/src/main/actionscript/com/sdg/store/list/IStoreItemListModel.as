package com.sdg.store.list
{
	import com.sdg.model.StoreItem;
	import com.sdg.model.StoreItemCollection;
	
	import flash.events.IEventDispatcher;
	
	public interface IStoreItemListModel extends IEventDispatcher
	{
		function init(view:IStoreItemListView, controller:IStoreItemListController):void;
		function updateItemQuantity(storeItem:StoreItem):void;
		
		function get itemCollection():StoreItemCollection;
		function set itemCollection(value:StoreItemCollection):void;
		function get view():IStoreItemListView;
		function get controller():IStoreItemListController;
		function get defaultWidth():Number;
		function get defaultHeight():Number;
		function get backgroundUrl():String;
		function set backgroundUrl(value:String):void;
		function get windowBackgroundUrl():String;
		function set windowBackgroundUrl(value:String):void;
		function get itemSetName():String;
		function set itemSetName(value:String):void;
		function get userLevel():uint;
		function set userLevel(value:uint):void;
		function get userSubLevel():uint;
		function set userSubLevel(value:uint):void;
		function get itemSetImageUrl():String;
		function set itemSetImageUrl(value:String):void;
		function get userTokens():int;
		function set userTokens(value:int):void;
	}
}
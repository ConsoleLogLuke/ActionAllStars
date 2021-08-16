package com.sdg.store.preview
{
	import com.sdg.model.Avatar;
	import com.sdg.model.IPreviewItem;
	import com.sdg.model.StoreItem;
	
	import flash.events.IEventDispatcher;
	
	public interface IStoreAvatarPreviewModel extends IEventDispatcher
	{
		function init(view:IStoreAvatarPreviewView, controller:IStoreAvatarPreviewController):void;
		function resetClothing():void;
		function addItem(item:IPreviewItem):void
		function addItemSet(setItem:StoreItem):void
		
		function get view():IStoreAvatarPreviewView;
		function get controller():IStoreAvatarPreviewController;
		function get avatar():Avatar;
		function get defaultWidth():Number;
		function get defaultHeight():Number;
		function set avatar(value:Avatar):void;
		function get currentApparelUrls():Array;
		function get backgroundUrl():String;
		function set backgroundUrl(value:String):void;
		function get addTokensButtonUrl():String;
	}
}
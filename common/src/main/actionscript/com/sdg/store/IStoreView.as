package com.sdg.store
{
	import com.sdg.mvc.IView;
	import com.sdg.store.home.IStoreHomeView;
	import com.sdg.store.list.IStoreItemListView;
	import com.sdg.store.nav.IStoreNavView;
	import com.sdg.store.preview.IStoreAvatarPreviewView;
	
	import flash.display.DisplayObject;
	
	public interface IStoreView extends IView
	{
		function init(width:Number, height:Number):void;
		function goToBrowseView():void;
		function goToHomeView():void;
		function hideShopKeeper():void;
		
		function set navView(value:IStoreNavView):void;
		function set itemListView(value:IStoreItemListView):void;
		function set avatarPreviewView(value:IStoreAvatarPreviewView):void;
		function set toolTip(value:ToolTip):void;
		function set homeView(value:IStoreHomeView):void;
		function set background(value:DisplayObject):void;
		function set shopKeeperDisplay(value:DisplayObject):void;
	}
}
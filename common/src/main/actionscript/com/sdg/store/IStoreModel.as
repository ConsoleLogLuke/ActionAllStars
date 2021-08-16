package com.sdg.store
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.StoreItemCollection;
	import com.sdg.mvc.IModel;
	import com.sdg.net.RemoteSoundBank;
	import com.sdg.store.home.IStoreHomeView;
	import com.sdg.store.list.IStoreItemListModel;
	import com.sdg.store.nav.IStoreNavModel;
	import com.sdg.store.preview.IStoreAvatarPreviewModel;
	import com.sdg.store.skin.IStoreSkin;
	
	public interface IStoreModel extends IModel
	{	
		function get view():IStoreView;
		function get controller():IStoreController;
		
		function get itemListModel():IStoreItemListModel;
		function get navModel():IStoreNavModel;
		function get avatarPreviewModel():IStoreAvatarPreviewModel;
		function get defaultWidth():Number;
		function get defaultHeight():Number;
		function get avatar():Avatar;
		function get items():StoreItemCollection;
		function get skin():IStoreSkin;
		function get toolTip():ToolTip;
		function get remoteSoundBank():RemoteSoundBank;
		function get coinSoundUrl():String;
		function get storeId():uint;
		function get categoryId():uint;
		function set categoryId(value:uint):void;
		function get homeView():IStoreHomeView;
		function get backgroundUrl():String;
		function get shopKeeperUrl():String;
		
		function getAllStores():Object;
		function getAllStoreCategories(storeId:uint):Object;
		function getAllCategoryItems(storeId:uint, categoryId:uint):Object;
		function updateInventory():void;
		function selectCategory(categoryId:uint):void;
	}
}
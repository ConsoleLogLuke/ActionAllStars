package com.sdg.store.nav
{
	import com.sdg.model.Store;
	import com.sdg.net.RemoteSoundBank;
	
	import flash.events.IEventDispatcher;
		
	public interface IStoreNavModel extends IEventDispatcher
	{
		function init(view:IStoreNavView, controller:IStoreNavController):void;
		
		function get view():IStoreNavView;
		function get controller():IStoreNavController;
		function get defaultWidth():Number;
		function get defaultHeight():Number;
		function get remoteSoundBank():RemoteSoundBank;
		function get store():Store;
		function set store(value:Store):void;
		function get storeId():uint;
		function set storeId(value:uint):void;
		function get storeName():String;
		function set storeName(value:String):void;
		function get buttons():Object
		function set buttons(value:Object):void;
		function get currentCategory():Number;
		function set currentCategory(value:Number):void;
		function resetCurrentCategory():void;
		//function get categorySelectHistory():int;
		//function set categorySelectHistory(value:int):void;
		//function get navBorderUrl():String;
		function setNavBorderUrls(navBorderTop:String,navBorderMiddle:String,navBorderBottom:String):void
		function get navBorderTopUrl():String;
		function get navBorderMiddleUrl():String;
		function get navBorderBottomUrl():String;
		function get rolloverSoundUrl():String;
		function get selectSoundUrl():String;
	}
}
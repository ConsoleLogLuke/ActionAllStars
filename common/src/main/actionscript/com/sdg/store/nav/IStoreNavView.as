package com.sdg.store.nav
{
	import com.sdg.mvc.IView;
	
	import flash.display.DisplayObject;
	
	public interface IStoreNavView extends IView
	{
		function init(width:Number, height:Number):void;
		function updateNavBorder(borderImage:DisplayObject,location:String):void;
		function setBorderMiddleUrl(url:String):void;
		function setBorderDimensions(width:uint,height:uint):void;
		function setBorderStoreId(value:uint):void;
		//function updateMovieBorder(movie:MovieClip):void;
		//function addItem(id:uint, name:String, parentPath:Array = null):IEventDispatcher;

		function get buttonList():Array;
		function set buttonList(value:Array):void;
	}
}
package com.sdg.store.item
{
	import com.sdg.mvc.IView;
	
	import flash.display.DisplayObject;
	
	public interface IStoreItemView extends IView
	{
		function init(width:Number, height:Number):void;
		function set levelRequirement(value:int):void;
		function get levelRequirement():int;
		function set isLocked(value:Boolean):void;
		function get isLocked():Boolean;
		function get thumbnail():DisplayObject;
		function set thumbnail(value:DisplayObject):void;
		function set itemName(value:String):void;
		function get itemName():String;
		function set numTokens(value:int):void;
		function get numTokens():int;
		function get itemTypeId():uint;
		function set itemTypeId(value:uint):void;
		function get itemId():uint;
		function set itemId(value:uint):void;
		function get listOrderId():uint;
		function set listOrderId(value:uint):void;
		function get purchasedAmount():int;
		function set purchasedAmount(value:int):void;
		function get homeTurfValue():uint;
		function set homeTurfValue(value:uint):void;
		function get isAffordable():Boolean;
		function set isAffordable(value:Boolean):void;
	}
}

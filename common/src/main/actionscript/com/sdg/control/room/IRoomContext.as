package com.sdg.control.room
{
	import com.sdg.control.room.itemClasses.*;
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.model.Room;
	import com.sdg.model.SdgItem;
	import com.sdg.view.IRoomView;
	
	import flash.events.IEventDispatcher;
	
	public interface IRoomContext extends IEventDispatcher
	{
		function get room():Room;
		
		function get roomView():IRoomView;
		
		function get progressInfo():IProgressInfo;
		
		function clear():void;
		
		function addItemController(item:SdgItem, controller:IRoomItemController):void;
		
		function getItemController(item:SdgItem, createIfNull:Boolean = true):IRoomItemController;
		
		function removeItemController(item:SdgItem):void;
		
		function addItemDisplay(layer:uint, display:IRoomItemDisplay):void;
		
		function removeItemDisplay(display:IRoomItemDisplay):void;
		
		function addMapEntity(layer:uint, entity:RoomEntity):void;
		
		function removeMapEntity(entity:RoomEntity):void;
		
		function changeEntityMap(entity:RoomEntity, newMapLayer:uint):void;
		
		function setUpRoom():void;
		
		function getItemControllerWithInventoryId(inventoryItemId:int):IRoomItemController;
	}
}
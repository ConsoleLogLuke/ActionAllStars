package com.sdg.control.room.itemClasses
{
	import com.sdg.control.room.IRoomContext;
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.model.SdgItem;
	
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	public interface IRoomItemController extends IEventDispatcher
	{
		function get context():IRoomContext;
		function set context(value:IRoomContext):void;
		
		function get itemResolveStatus():uint;
		function set itemResolveStatus(value:uint):void;
		
		function get display():IRoomItemDisplay;
		
		function get entity():RoomEntity;
		
		function get item():SdgItem;
		
		function get progressInfo():IProgressInfo;
		
		function initialize(item:SdgItem):void;
		
		function getEditor():IRoomItemEditor;
		
		function processAction(action:String, params:Object):void;
		
		function destroy():void;
	}
}
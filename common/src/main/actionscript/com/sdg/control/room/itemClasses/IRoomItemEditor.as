package com.sdg.control.room.itemClasses
{
	public interface IRoomItemEditor
	{
		function get owner():IRoomItemController;
		
		function get isDragging():Boolean;
		
		function get isValid():Boolean;
		
		function get inspectable():Boolean;
		function set inspectable(value:Boolean):void;
		
		function get selected():Boolean;
		function set selected(value:Boolean):void;
		
		function startDrag(relative:Boolean = true):void;
		
		function stopDrag():void;
	}
}
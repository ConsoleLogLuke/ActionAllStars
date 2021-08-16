package com.sdg.control.room
{
	import com.sdg.control.IDynamicController;

	public interface IRoomSpecificController extends IDynamicController
	{
		function initRoom(roomController:RoomController):void;
	}
}
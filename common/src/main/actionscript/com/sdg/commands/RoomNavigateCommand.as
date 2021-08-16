package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.RoomNavigateEvent;
	
	public class RoomNavigateCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:RoomNavigateEvent = RoomNavigateEvent(event);
			var roomManager:RoomManager = RoomManager.getInstance();
			
			switch (ev.type)
			{
				case RoomNavigateEvent.ENTER_ROOM:
					roomManager.enterRoom(ev.roomId);
					break;
				
				case RoomNavigateEvent.ENTER_PREV_ROOM:
					roomManager.enterRoom(roomManager.prevRoomId, false);
					break;
			
				case RoomNavigateEvent.EXIT_ROOM:
					roomManager.exitRoom();
					break;
			}
		}
	}
}
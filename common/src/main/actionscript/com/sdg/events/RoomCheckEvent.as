package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class RoomCheckEvent extends CairngormEvent
	{
		public static const CHECK_ROOM:String = "check room";
		public static const ROOM_CHECKED:String = "room checked";
		public static const ITEM_CHECK_ROOMID:int = 0; // Alternate Item Ownership Check
		
		public var avatarId:int;
		public var roomId:int;
		public var status:int;
		public var codeId:int;
		public var itemId:int;
		
		public function RoomCheckEvent(avatarId:int, roomId:int, type:String = CHECK_ROOM, status:int = 0, codeId:int = 0, itemId:int=0)
		{
			super(type);
			this.avatarId = avatarId;
			this.roomId = roomId;
			this.status = status;
			this.codeId = codeId;
			this.itemId = itemId;
		}
	}
}
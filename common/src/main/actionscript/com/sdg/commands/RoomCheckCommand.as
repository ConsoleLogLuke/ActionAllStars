package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.RoomCheckEvent;
	
	import mx.rpc.IResponder;
	
	public class RoomCheckCommand implements ICommand, IResponder
	{
		private var _event:RoomCheckEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as RoomCheckEvent;
			if (_event.roomId != RoomCheckEvent.ITEM_CHECK_ROOMID)
			{
				new SdgServiceDelegate(this).checkRoom(_event.avatarId, _event.roomId);
			}
			else
			{
				new SdgServiceDelegate(this).checkItemOwnership(_event.avatarId, _event.itemId);
			}
		}
		
		public function result(data:Object):void
		{
			trace(data);
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomCheckEvent(_event.avatarId,
																					_event.roomId,
																					RoomCheckEvent.ROOM_CHECKED,
																					data.@status));
		}
		
		public function fault(info:Object):void
		{
			trace(info);
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomCheckEvent(_event.avatarId,
																					_event.roomId,
																					RoomCheckEvent.ROOM_CHECKED,
																					info.@status,
																					info.codeId));
			
		}
	}
}
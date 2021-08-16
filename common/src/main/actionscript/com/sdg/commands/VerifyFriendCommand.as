package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.VerifyFriendEvent;
	
	import mx.rpc.IResponder;
		
	public class VerifyFriendCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _event:VerifyFriendEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as VerifyFriendEvent
			new SdgServiceDelegate(this).verifyFriend(_event.friendName);
		}
		
		public function result(data:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new VerifyFriendEvent(_event.friendName, VerifyFriendEvent.FRIEND_VERIFIED, true));
		}
		
		override public function fault(info:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new VerifyFriendEvent(_event.friendName, VerifyFriendEvent.FRIEND_VERIFIED, false));
		}
	}
}

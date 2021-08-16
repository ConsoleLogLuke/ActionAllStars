package com.sdg.messageBoard.models
{
	import com.sdg.model.Buddy;
	
	import flash.events.EventDispatcher;
	
	public class AddMessageModel extends EventDispatcher
	{
		private var _turfMessage:TurfMessage;
		
		public function AddMessageModel(sender:Buddy, recipientId:int)
		{
			_turfMessage = new TurfMessage();
			_turfMessage.sender = sender;
			_turfMessage.recipientId = recipientId;
		}
		
		public function close():void
		{
			
		}
		
		public function get turfMessage():TurfMessage
		{
			return _turfMessage;
		}
	}
}
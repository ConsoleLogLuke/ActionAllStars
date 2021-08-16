package com.sdg.messageBoard.models
{
	import com.sdg.messageBoard.events.TurfMessageEvent;
	import com.sdg.model.Buddy;
	
	import flash.events.EventDispatcher;
	
	public class TurfMessage extends EventDispatcher
	{
		protected var _sender:Buddy;
		protected var _message:String;
		protected var _stickerId:Object;
		protected var _bgId:Object;
		protected var _messageId:int;
		protected var _recipientId:int;
		
		public function TurfMessage()
		{
			_message = "";
		}
		
		public function set sender(value:Buddy):void
		{
			_sender = value;
		}
		
		public function get sender():Buddy
		{
			return _sender;
		}
		
		public function set message(value:String):void
		{
			_message = value;
		}
		
		public function get message():String
		{
			return _message;
		}
		
		public function set stickerId(value:Object):void
		{
			_stickerId = value;
			dispatchEvent(new TurfMessageEvent(TurfMessageEvent.STICKER_ID_CHANGE));
		}
		
		public function get stickerId():Object
		{
			return _stickerId;
		}
		
		public function set bgId(value:Object):void
		{
			_bgId = value;
			dispatchEvent(new TurfMessageEvent(TurfMessageEvent.BG_ID_CHANGE));
		}
		
		public function get bgId():Object
		{
			return _bgId;
		}
		
		public function set messageId(value:int):void
		{
			_messageId = value;
		}
		
		public function get messageId():int
		{
			return _messageId;
		}
		
		public function set recipientId(value:int):void
		{
			_recipientId = value;
		}
		
		public function get recipientId():int
		{
			return _recipientId;
		}
	}
}
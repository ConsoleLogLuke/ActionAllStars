package com.sdg.messageBoard.events
{
	import com.sdg.messageBoard.models.TurfMessage;
	
	import flash.events.Event;

	public class MessageBoardEvent extends Event
	{
		public static var MESSAGE_LIST_UPDATED:String = "message list updated";
		public static var MESSAGE_DELETED:String = "message deleted";
		public static var ADD_MESSAGE:String = "add message";
		public static var REPLY_MESSAGE:String = "reply message";
		public static var CLOSE_ADD_MESSAGE:String = "close add message";
		public static var POST_IT:String = "post it";
		public static var CLOSE_MESSAGE_BOARD:String = "close message board";
		public static var DELETE_MESSAGE:String = "delete message";
		public static var REPORT_MESSAGE:String = "report message";
		public static var ADD_BUDDY:String = "add buddy";
		public static var REMOVE_BUDDY:String = "remove buddy";
		public static var GO_TO_SENDER_TURF:String = "go to sender turf";
		
		public var turfMessage:TurfMessage;
		public var recipientId:int;
		
		public function MessageBoardEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class MessageBoardServerEvent extends CairngormEvent
	{
		public static const GET_MESSAGES:String = "get messages";
		public static const POST_MESSAGE:String = "post message";
		public static const UPDATE_MESSAGE:String = "update message";
		
		public static const MESSAGES_RESPONSE:String = "messages response";
		public static const POST_RESPONSE:String = "post response";
		public static const UPDATE_RESPONSE:String = "update response";
		
		public static const ACTION_TYPE_DELETE:int = 1;
		public static const ACTION_TYPE_REPORT:int = 2;
		
		public var message:String;
		public var messageId:int;
		public var actionType:int;
		public var returnObj:Object;
		public var requestEvent:MessageBoardServerEvent;
		public var recipientId:int;
		
		public function MessageBoardServerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
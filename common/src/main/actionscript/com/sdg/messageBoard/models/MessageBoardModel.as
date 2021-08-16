package com.sdg.messageBoard.models
{
	import com.sdg.messageBoard.events.MessageBoardEvent;
	import com.sdg.model.Buddy;
	import com.sdg.model.Room;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class MessageBoardModel extends EventDispatcher
	{
		protected var _messages:ArrayCollection;
		protected var _currentRoom:Room
		
		public function MessageBoardModel(currentRoom:Room)
		{
			_currentRoom = currentRoom;
		}
		
		public function get messages():ArrayCollection
		{
			if (_messages == null)
				_messages = new ArrayCollection();
			
			return _messages;
		}
		
		public function get currentRoom():Room
		{
			return _currentRoom;
		}
		
		public function removeMessage(messageId:int):void
		{
			for (var index:int = 0; index < _messages.length; index++)
			{
				if (_messages[index].messageId == messageId)
				{
					_messages.removeItemAt(index);
					dispatchEvent(new MessageBoardEvent(MessageBoardEvent.MESSAGE_DELETED));
					break;
				} 
			}
		}
		
		public function setMessageList(value:Object):void
		{
			_messages = new ArrayCollection();
			var messagesXmlList:XMLList = value.messages;
			for each(var messageXml:XML in messagesXmlList.inboxMessage)
			{
				_messages.addItem(createTurfMessage(messageXml));
			}
			
			dispatchEvent(new MessageBoardEvent(MessageBoardEvent.MESSAGE_LIST_UPDATED));
		}
		
		private function createTurfMessage(messageXml:XML):TurfMessage
		{
			var turfMessage:TurfMessage = new TurfMessage();
			turfMessage.messageId = messageXml.inboxMessageId;
			var sender:Buddy = new Buddy();
			sender.avatarId = messageXml.fromAvatarId;
			var messageTextArray:Array = String(messageXml.text).split("~");
			sender.name = messageTextArray[0];
			sender.gender = messageTextArray[1];
			sender.level = messageTextArray[2];
			turfMessage.stickerId = messageTextArray[3];
			turfMessage.bgId = messageTextArray[4];
			turfMessage.message = messageTextArray[5];
			turfMessage.sender = sender;
			
			return turfMessage;
		}
		
		public function addMessage(value:Object):void
		{
			_messages.addItemAt(createTurfMessage(value.inboxMessage[0]), 0);
			dispatchEvent(new MessageBoardEvent(MessageBoardEvent.MESSAGE_LIST_UPDATED));
		}
		
		public function close():void
		{
			
		}
	}
}
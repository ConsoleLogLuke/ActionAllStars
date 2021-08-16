package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.MessageBoardServerEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Server;
	
	import mx.rpc.IResponder;
	
	public class MessageBoardServerCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _event:MessageBoardServerEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as MessageBoardServerEvent;
			var service:SdgServiceDelegate = new SdgServiceDelegate(this);
			var modelLocator:ModelLocator = ModelLocator.getInstance();
			var userAvatarId:int = modelLocator.avatar.avatarId;
			var password:String = modelLocator.user.password;
			var ct:Number = (new Date()).time;
			
			if (_event.type == MessageBoardServerEvent.GET_MESSAGES)
				service.messageBoardList(_event.recipientId, ct);
			else if (_event.type == MessageBoardServerEvent.POST_MESSAGE)
			{
				service.messageBoardAdd(_event.recipientId, userAvatarId, _event.message, ct, password);
			}
			else if (_event.type == MessageBoardServerEvent.UPDATE_MESSAGE)
				service.messageBoardUpdate(userAvatarId, _event.messageId, _event.actionType, ct, password, Server.getCurrentId());
		}
		
		public function result(data:Object):void
		{
			handleResponse(data);
		}
		
		override public function fault(info:Object):void
		{
			handleResponse(info);
		}
		
		private function handleResponse(returnObj:Object = null):void
		{
			var eventType:String;
			
			if (_event.type == MessageBoardServerEvent.GET_MESSAGES)
				eventType = MessageBoardServerEvent.MESSAGES_RESPONSE;
			else if (_event.type == MessageBoardServerEvent.POST_MESSAGE)
				eventType = MessageBoardServerEvent.POST_RESPONSE;
			else if (_event.type == MessageBoardServerEvent.UPDATE_MESSAGE)
				eventType = MessageBoardServerEvent.UPDATE_RESPONSE;
			
			var event:MessageBoardServerEvent = new MessageBoardServerEvent(eventType);
			event.returnObj = returnObj;
			event.requestEvent = _event;
			CairngormEventDispatcher.getInstance().dispatchEvent(event);
		}
	}
}
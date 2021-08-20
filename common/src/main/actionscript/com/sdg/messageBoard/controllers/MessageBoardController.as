package com.sdg.messageBoard.controllers
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.control.BuddyManager;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.MessageBoardServerEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.messageBoard.AddMessageDialog;
	import com.sdg.messageBoard.events.MessageBoardEvent;
	import com.sdg.messageBoard.models.AddMessageModel;
	import com.sdg.messageBoard.models.MessageBoardModel;
	import com.sdg.messageBoard.models.TurfMessage;
	import com.sdg.messageBoard.views.AddMessageView;
	import com.sdg.messageBoard.views.CorkBoardView;
	import com.sdg.model.Avatar;
	import com.sdg.model.Buddy;
	import com.sdg.model.ModelLocator;
	import com.sdg.utils.MainUtil;

	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import mx.core.FlexGlobals; // Non-SDG - Application to FlexGlobals

	public class MessageBoardController extends EventDispatcher
	{
		private var _view:CorkBoardView;
		private var _model:MessageBoardModel;
		private var _addMessageView:AddMessageView;
		private var _addMessageModel:AddMessageModel;
		private var _addMessageDialog:AddMessageDialog;

		public function MessageBoardController()
		{
			_model = new MessageBoardModel(RoomManager.getInstance().currentRoom);
			_view = new CorkBoardView(_model);

			// add event listeners to view
			_view.addEventListener(MessageBoardEvent.ADD_MESSAGE, onAddMessage, false, 0, true);
			_view.addEventListener(MessageBoardEvent.REPLY_MESSAGE, onReplyMessage, false, 0, true);
			_view.addEventListener(MessageBoardEvent.DELETE_MESSAGE, onDeleteMessage, false, 0, true);
			_view.addEventListener(MessageBoardEvent.REPORT_MESSAGE, onReportMessage, false, 0, true);
			_view.addEventListener(MessageBoardEvent.CLOSE_MESSAGE_BOARD, onCloseMessageBoard, false, 0, true);
			_view.addEventListener(MessageBoardEvent.ADD_BUDDY, onAddBuddy, false, 0, true);
			_view.addEventListener(MessageBoardEvent.REMOVE_BUDDY, onRemoveBuddy, false, 0, true);
			_view.addEventListener(MessageBoardEvent.GO_TO_SENDER_TURF, onGoToTurf, false, 0, true);

			getMessages();
		}

		private function onAddBuddy(event:MessageBoardEvent):void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_ADD_FRIEND);
			var sender:Buddy = event.turfMessage.sender;
			BuddyManager.makeBuddyRequest(sender.avatarId, sender.name);
		}

		private function onRemoveBuddy(event:MessageBoardEvent):void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_REMOVE_FRIEND);
			var sender:Buddy = event.turfMessage.sender;
			BuddyManager.makeRemoveBuddyRequest(sender.avatarId);
		}

		private function onGoToTurf(event:MessageBoardEvent):void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_GO_TO_TURF);
			var sender:Buddy = event.turfMessage.sender;
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, "private_" + sender.avatarId + "_1"));
			close();
		}

		private function onCloseMessageBoard(event:MessageBoardEvent):void
		{
			close();
		}

		private function onReportMessage(event:MessageBoardEvent):void
		{
			updateMessage(event.turfMessage, MessageBoardServerEvent.ACTION_TYPE_REPORT);
		}

		private function onDeleteMessage(event:MessageBoardEvent):void
		{
			updateMessage(event.turfMessage, MessageBoardServerEvent.ACTION_TYPE_DELETE);
		}

		private function updateMessage(turfMessage:TurfMessage, actionType:int):void
		{
			CairngormEventDispatcher.getInstance().addEventListener(MessageBoardServerEvent.UPDATE_RESPONSE, onUpdateResponse);
			var event:MessageBoardServerEvent = new MessageBoardServerEvent(MessageBoardServerEvent.UPDATE_MESSAGE);
			event.messageId = turfMessage.messageId;
			event.actionType = actionType;
			CairngormEventDispatcher.getInstance().dispatchEvent(event);
		}

		private function onReplyMessage(event:MessageBoardEvent):void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_REPLY);
			addMessage(event.recipientId);
		}

		private function onAddMessage(event:MessageBoardEvent):void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_ADD_MESSAGE);
			addMessage(event.recipientId);
		}

		private function addMessage(recipientId:int):void
		{
			// Send the stage to normal display state.
			FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.NORMAL;

			var avatar:Avatar = ModelLocator.getInstance().avatar;

			var sender:Buddy = new Buddy();
			sender.name = avatar.name;
			sender.level = avatar.level;
			sender.gender = avatar.gender;

			_addMessageModel = new AddMessageModel(sender, recipientId);
			_addMessageView = new AddMessageView(_addMessageModel);

			_addMessageView.addEventListener(MessageBoardEvent.POST_IT, onPostIt, false, 0, true);
			_addMessageView.addEventListener(MessageBoardEvent.CLOSE_ADD_MESSAGE, onCloseAddMessage, false, 0, true);

			_addMessageDialog = MainUtil.showDialog(AddMessageDialog, this) as AddMessageDialog;
		}

		private function onCloseAddMessage(event:MessageBoardEvent):void
		{
			closeAddMessage();
		}

		private function closeAddMessage():void
		{
			_addMessageModel.close();
			_addMessageView.close();

			_addMessageView.removeEventListener(MessageBoardEvent.POST_IT, onPostIt);
			_addMessageView.removeEventListener(MessageBoardEvent.CLOSE_ADD_MESSAGE, onCloseAddMessage);

			_addMessageDialog.close();
		}

		private function onPostIt(event:MessageBoardEvent):void
		{
			postMessage(event.turfMessage);
		}

		private function postMessage(turfMessage:TurfMessage):void
		{
			CairngormEventDispatcher.getInstance().addEventListener(MessageBoardServerEvent.POST_RESPONSE, onPostResponse);
			var event:MessageBoardServerEvent = new MessageBoardServerEvent(MessageBoardServerEvent.POST_MESSAGE);
			event.message = convertToServerMessage(turfMessage);
			event.recipientId = turfMessage.recipientId;
			CairngormEventDispatcher.getInstance().dispatchEvent(event);
		}

		private function convertToServerMessage(turfMessage:TurfMessage):String
		{
			var messageString:String;

			var sender:Buddy = turfMessage.sender;
			messageString = sender.name + "~" + sender.gender + "~" + sender.level +
				"~" + turfMessage.stickerId + "~" + turfMessage.bgId + "~" + turfMessage.message;

			return messageString;
		}

		private function getMessages():void
		{
			CairngormEventDispatcher.getInstance().addEventListener(MessageBoardServerEvent.MESSAGES_RESPONSE, onMessagesResponse);
			var event:MessageBoardServerEvent = new MessageBoardServerEvent(MessageBoardServerEvent.GET_MESSAGES);
			event.recipientId = _model.currentRoom.ownerId;
			CairngormEventDispatcher.getInstance().dispatchEvent(event);
		}

		private function close():void
		{
			_model.close();
			_view.close();

			_view.removeEventListener(MessageBoardEvent.ADD_MESSAGE, onAddMessage);
			_view.removeEventListener(MessageBoardEvent.REPLY_MESSAGE, onReplyMessage);
			_view.removeEventListener(MessageBoardEvent.DELETE_MESSAGE, onDeleteMessage);
			_view.removeEventListener(MessageBoardEvent.REPORT_MESSAGE, onReportMessage);
			_view.removeEventListener(MessageBoardEvent.CLOSE_MESSAGE_BOARD, onCloseMessageBoard);
			_view.removeEventListener(MessageBoardEvent.ADD_BUDDY, onAddBuddy);
			_view.removeEventListener(MessageBoardEvent.REMOVE_BUDDY, onRemoveBuddy);
			_view.removeEventListener(MessageBoardEvent.GO_TO_SENDER_TURF, onGoToTurf);

			dispatchEvent(new Event(Event.CLOSE, true));
		}

		private function onUpdateResponse(event:MessageBoardServerEvent):void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(MessageBoardServerEvent.UPDATE_RESPONSE, onUpdateResponse);

			var returnObj:Object = event.returnObj;
			var status:int = returnObj.@status;
			var requestEvent:MessageBoardServerEvent = event.requestEvent;
			var actionType:int = requestEvent.actionType;

			if (status == 1)
			{
				if (actionType == MessageBoardServerEvent.ACTION_TYPE_DELETE)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_DELETE_MESSAGE);
					_model.removeMessage(requestEvent.messageId);
				}
				else if (actionType == MessageBoardServerEvent.ACTION_TYPE_REPORT)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_REPORT_MESSAGE);
					_view.showReportSuccess();
				}
			}
			else
			{
				_view.handleUpdateError(actionType);
			}
		}

		private function onPostResponse(event:MessageBoardServerEvent):void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(MessageBoardServerEvent.POST_RESPONSE, onPostResponse);

			var returnObj:Object = event.returnObj;
			var status:int = returnObj.@status;

			if (status == 1)
			{
				if (event.requestEvent.recipientId != _model.currentRoom.ownerId)
				{
					_view.showReplySuccess();
				}
				else
				{
					LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_POST_IT);
					_model.addMessage(returnObj);
				}
				closeAddMessage();
			}
			else if (status == 302)
			{
				_addMessageView.handleChatFilterError(returnObj.badWords.split(","));
			}
			else
			{
				_addMessageView.handlePostError();
			}
		}

		private function onMessagesResponse(event:MessageBoardServerEvent):void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(MessageBoardServerEvent.MESSAGES_RESPONSE, onMessagesResponse);

			var returnObj:Object = event.returnObj;
			var status:int = returnObj.@status;

			if (status == 1)
			{
				_model.setMessageList(returnObj);
			}
			else
			{
				_view.handleMessageListError();
			}
		}

		public function get addMessageView():AddMessageView
		{
			return _addMessageView;
		}

		public function get view():CorkBoardView
		{
			return _view;
		}
	}
}

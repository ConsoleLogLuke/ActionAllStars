package com.sdg.messageBoard.views
{
	import com.sdg.components.controls.ModeratorAlertChrome;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.BuddyManager;
	import com.sdg.events.MessageBoardServerEvent;
	import com.sdg.messageBoard.events.MessageBoardEvent;
	import com.sdg.messageBoard.models.MessageBoardModel;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	
	public class CorkBoardView extends Sprite
	{
		private static const NUM_ROWS:int = 2;
		private static const NUM_COLUMNS:int = 4;
		
		private var _model:MessageBoardModel;
		private var _page:int;
		private var _leftButton:DisplayObject;
		private var _rightButton:DisplayObject;
		private var _replyButton:DisplayObject;
		private var _deleteButton:DisplayObject;
		private var _addFriendButton:DisplayObject;
		private var _removeFriendButton:DisplayObject;
		private var _friendButton:DisplayObject;
		private var _goHomeTurfButton:DisplayObject;
		private var _addMessageButton:DisplayObject;
		private var _closeButton:DisplayObject;
		private var _reportButton:DisplayObject;
		
		private var _messageContainer:Sprite;
		private var _selectedMessage:TurfMessageView;
		private var _pageNumTF:TextField;
		private var _toolTipTF:TextField;
		
		public function CorkBoardView(model:MessageBoardModel)
		{
			super();
			
			_model = model;
			
			_model.addEventListener(MessageBoardEvent.MESSAGE_LIST_UPDATED, onMessageListUpdated, false, 0, true);
			_model.addEventListener(MessageBoardEvent.MESSAGE_DELETED, onMessageDeleted, false, 0, true);
			
			var background:QuickLoader = new QuickLoader("assets/swfs/turfBuilder/msgBoard/MsgBoard.swf", onBGComplete);
			
			// page number
			_pageNumTF = new TextField();
			_pageNumTF.embedFonts = true;
			_pageNumTF.defaultTextFormat = new TextFormat('EuroStyle', 19, 0x4c4936, true);
			_pageNumTF.autoSize = TextFieldAutoSize.LEFT;
			_pageNumTF.selectable = false;
			_pageNumTF.y = 96;
			addChild(_pageNumTF);
			
			_leftButton = new QuickLoader("assets/swfs/turfBuilder/msgBoard/LeftArrow.swf", onLeftArrowComplete);
			_rightButton = new QuickLoader("assets/swfs/turfBuilder/msgBoard/RightArrow.swf", onRightArrowComplete);
			
			_replyButton = new QuickLoader("assets/swfs/turfBuilder/msgBoard/ReplyMessage.swf", onReplyButtonComplete);
			_deleteButton = new QuickLoader("assets/swfs/turfBuilder/msgBoard/DeleteMessage.swf", onDeleteButtonComplete);
			
			_goHomeTurfButton = new CircleIconVisit();
			_goHomeTurfButton.scaleX = _goHomeTurfButton.scaleY = 1.3;
			_goHomeTurfButton.x = 214;
			_goHomeTurfButton.y = 580;
			_goHomeTurfButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_goHomeTurfButton);
			Sprite(_goHomeTurfButton).buttonMode = true;
			_goHomeTurfButton.addEventListener(MouseEvent.CLICK, onHomeTurfButtonClick, false, 0, true);
			_goHomeTurfButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver, false, 0, true);
			_goHomeTurfButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut, false, 0, true);
			
			_reportButton = new QuickLoader("assets/swfs/turfBuilder/msgBoard/ReportUser.swf", onReportButtonComplete);
			
			_addMessageButton = new QuickLoader("assets/swfs/turfBuilder/msgBoard/AddMessage.swf", onAddMessageButtonComplete);
			
			_toolTipTF = new TextField();
			_toolTipTF.embedFonts = true;
			_toolTipTF.defaultTextFormat = new TextFormat('EuroStyle', 17, 0xffffff, true);
			_toolTipTF.autoSize = TextFieldAutoSize.LEFT;
			_toolTipTF.selectable = false;
			_toolTipTF.x = 389;
			_toolTipTF.y = 565;
			_toolTipTF.filters = [new GlowFilter(0x000000, 1, 6, 6, 10)];
			addChild(_toolTipTF);
			
			_closeButton = new QuickLoader("assets/swfs/turfBuilder/msgBoard/ButtonClose.swf", onCloseButtonComplete);
			
			setPage(0);
			
			function onBGComplete():void
			{
				addChildAt(background.content, 0);
				_pageNumTF.x = width/2 - _pageNumTF.width/2;
			}
		}
		
		private function onCloseButtonComplete():void
		{
			_closeButton = QuickLoader(_closeButton).content;
			_closeButton.x = 862;
			_closeButton.y = 40;
			addChild(_closeButton);
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClick, false, 0, true);
		}
		
		private function onCloseButtonClick(event:MouseEvent):void
		{
			dispatchEvent(new MessageBoardEvent(MessageBoardEvent.CLOSE_MESSAGE_BOARD));
		}
		
		private function onAddMessageButtonComplete():void
		{
			_addMessageButton = QuickLoader(_addMessageButton).content;
			_addMessageButton.x = 670;
			_addMessageButton.y = 555;
			_addMessageButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_addMessageButton);
			_addMessageButton.addEventListener(MouseEvent.CLICK, onAddMessageClick, false, 0, true);
		}
		
		private function onReplyClick(event:MouseEvent):void
		{
			dispatchAddMessageEvent(_selectedMessage.turfMessage.sender.avatarId, MessageBoardEvent.REPLY_MESSAGE);
		}
		
		private function onAddMessageClick(event:MouseEvent):void
		{
			dispatchAddMessageEvent(_model.currentRoom.ownerId, MessageBoardEvent.ADD_MESSAGE);
		}
		
		private function dispatchAddMessageEvent(recipientId:int, eventType:String):void
		{
			// Make sure the user is not in 'warned' mode.
			if (ModelLocator.getInstance().avatar.warned)
			{
				ModeratorAlertChrome.show("You are limited to scripted chat until your warning period expires.", "Warning Mode");
			}
			else
			{
				var event:MessageBoardEvent = new MessageBoardEvent(eventType);
				event.recipientId = recipientId;
				dispatchEvent(event);
			}
		}
		
		private function onReportButtonComplete():void
		{
			var loader:QuickLoader = _reportButton as QuickLoader;
			_reportButton = loader.content;
			_reportButton.scaleX = _reportButton.scaleY = 1.3;
			_reportButton.x = 328;
			_reportButton.y = 580;
			_reportButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_reportButton);
			Sprite(_reportButton).buttonMode = true;
			
			enableButton(_reportButton, loader.mouseEnabled);
			
			_reportButton.addEventListener(MouseEvent.CLICK, onReportClick, false, 0, true);
			_reportButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver, false, 0, true);
			_reportButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut, false, 0, true);
		}
		
		private function onReplyButtonComplete():void
		{
			var loader:QuickLoader = _replyButton as QuickLoader;
			_replyButton = loader.content;
			_replyButton.scaleX = _replyButton.scaleY = 1.3;
			_replyButton.x = 100;
			_replyButton.y = 580;
			_replyButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_replyButton);
			Sprite(_replyButton).buttonMode = true;
			
			enableButton(_replyButton, loader.mouseEnabled);
			
			_replyButton.addEventListener(MouseEvent.CLICK, onReplyClick, false, 0, true);
			_replyButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver, false, 0, true);
			_replyButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut, false, 0, true);
		}
		
		private function onDeleteButtonComplete():void
		{
			var loader:QuickLoader = _deleteButton as QuickLoader;
			_deleteButton = loader.content;
			_deleteButton.scaleX = _deleteButton.scaleY = 1.3;
			_deleteButton.x = 157;
			_deleteButton.y = 580;
			_deleteButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_deleteButton);
			Sprite(_deleteButton).buttonMode = true;
			
			enableButton(_deleteButton, loader.mouseEnabled);
			
			_deleteButton.addEventListener(MouseEvent.CLICK, onDeleteClick, false, 0, true);
			_deleteButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver, false, 0, true);
			_deleteButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut, false, 0, true);
		}
		
		private function onHomeTurfButtonClick(event:MouseEvent):void
		{
			var e:MessageBoardEvent = new MessageBoardEvent(MessageBoardEvent.GO_TO_SENDER_TURF);
			e.turfMessage = _selectedMessage.turfMessage;
			dispatchEvent(e);
		}
		
		private function onButtonMouseOver(event:MouseEvent):void
		{
			var button:DisplayObject = event.currentTarget as DisplayObject;
			var buttonFilters:Array = button.filters;
			buttonFilters.unshift(new GlowFilter(0xffffff, 1, 6, 6, 10));
			button.filters = buttonFilters;
			
			var tooltip:String = "";
			switch (button)
			{
				case _replyButton:
					tooltip = "Reply Message";
					break;
				case _deleteButton:
					tooltip = "Delete Message";
					break;
				case _goHomeTurfButton:
					tooltip = "Go To Sender's Turf";
					break;
				case _addFriendButton:
					tooltip = "Add Buddy";
					break;
				case _removeFriendButton:
					tooltip = "Remove Buddy";
					break;
				case _reportButton:
					tooltip = "Report Message";
					break;
			}
			
			_toolTipTF.text = tooltip;
		}
		
		private function onButtonMouseOut(event:MouseEvent):void
		{
			var button:DisplayObject = event.currentTarget as DisplayObject;
			var buttonFilters:Array = button.filters;
			buttonFilters.shift();
			button.filters = buttonFilters;
			_toolTipTF.text = "";
		}
		
		private function onLeftArrowComplete():void
		{
			var loader:QuickLoader = _leftButton as QuickLoader;
			_leftButton = loader.content;
			_leftButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_leftButton);
			_leftButton.x = 15;
			_leftButton.y = 300;
			_leftButton.visible = loader.visible;
			_leftButton.addEventListener(MouseEvent.CLICK, onArrowClick, false, 0, true);
		}
		
		private function onRightArrowComplete():void
		{
			var loader:QuickLoader = _rightButton as QuickLoader;
			_rightButton = loader.content;
			_rightButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_rightButton);
			_rightButton.x = 850;
			_rightButton.y = 300;
			_rightButton.visible = loader.visible;
			_rightButton.addEventListener(MouseEvent.CLICK, onArrowClick, false, 0, true);
		}
		
		private function onArrowClick(event:MouseEvent):void
		{
			var button:DisplayObject = event.currentTarget as DisplayObject;
			if (button == _leftButton)
			{
				setPage(_page - 1);
			}
			else
			{
				setPage(_page + 1);
			}
		}
		
		private function updateFriendButton():void
		{
			var button:DisplayObject;
			if (_selectedMessage != null && BuddyManager.isBuddy(_selectedMessage.turfMessage.sender.avatarId))
			{
				if (_removeFriendButton == null)
				{
					_removeFriendButton = new CircleIconUnfriend();
					_removeFriendButton.scaleX = _removeFriendButton.scaleY = 1.3;
					Sprite(_removeFriendButton).buttonMode = true;
				}
				
				button = _removeFriendButton;
			}
			else
			{
				if (_addFriendButton == null)
				{
					_addFriendButton = new CircleIconFriend();
					_addFriendButton.scaleX = _addFriendButton.scaleY = 1.3;
					Sprite(_addFriendButton).buttonMode = true;
				}
				
				button = _addFriendButton;
			}
			
			setFriendButton(button);
		}
			
		private function setFriendButton(button:DisplayObject):void
		{
			if (_friendButton == button) return;
			
			if (_friendButton != null)
			{
				_friendButton.removeEventListener(MouseEvent.CLICK, onFriendButtonClick);
				_friendButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
				_friendButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
				removeChild(_friendButton);
			}
				
			_friendButton = button;
			_friendButton.addEventListener(MouseEvent.CLICK, onFriendButtonClick, false, 0, true);
			_friendButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver, false, 0, true);
			_friendButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut, false, 0, true);
			_friendButton.filters = [new DropShadowFilter(10, 60, 0, .25)];
			addChild(_friendButton);
			_friendButton.x = 271;
			_friendButton.y = 580;
		}
		
		private	function onFriendButtonClick(event:MouseEvent):void
		{
			var eventType:String
			if (event.currentTarget == _addFriendButton)
			{
				eventType = MessageBoardEvent.ADD_BUDDY;
			}
			else if (event.currentTarget == _removeFriendButton)
			{
				eventType = MessageBoardEvent.REMOVE_BUDDY;
			}
			
			var e:MessageBoardEvent = new MessageBoardEvent(eventType);
			e.turfMessage = _selectedMessage.turfMessage;
			dispatchEvent(e);
		}
		
		private function onReportClick(event:MouseEvent):void
		{
			updateMessage(MessageBoardEvent.REPORT_MESSAGE);
		}
		
		private function onDeleteClick(event:MouseEvent):void
		{
			updateMessage(MessageBoardEvent.DELETE_MESSAGE);
		}
		
		private function updateMessage(eventType:String):void
		{
			var event:MessageBoardEvent = new MessageBoardEvent(eventType);
			event.turfMessage = _selectedMessage.turfMessage;
			dispatchEvent(event);
		}
		
		private function updateButtons():void
		{
			updateFriendButton();
			
			var replyButtonEnabled:Boolean;
			var deleteButtonEnabled:Boolean;
			var goHomeTurfButtonEnabled:Boolean;
			var friendButtonEnabled:Boolean;
			var reportButtonEnabled:Boolean;
			
			if (_selectedMessage != null)
			{
				var currentRoomOwnerId:int = _model.currentRoom.ownerId;
				var avatarId:int = ModelLocator.getInstance().avatar.avatarId;
				var senderId:int = _selectedMessage.turfMessage.sender.avatarId;
				
				if (currentRoomOwnerId == avatarId)
				{
					replyButtonEnabled = true;
					deleteButtonEnabled = true;
				}
				else if (senderId == avatarId)
					deleteButtonEnabled = true;
				
				if (senderId != currentRoomOwnerId)
					goHomeTurfButtonEnabled = true;
				
				if (senderId != avatarId)
					friendButtonEnabled = true;
				
				reportButtonEnabled = true;
			}
			
			enableButton(_replyButton, replyButtonEnabled);
			enableButton(_deleteButton, deleteButtonEnabled);
			enableButton(_goHomeTurfButton, goHomeTurfButtonEnabled);
			enableButton(_friendButton, friendButtonEnabled);
			enableButton(_reportButton, reportButtonEnabled);
		}
		
		private function enableButton(button:DisplayObject, value:Boolean):void
		{
			var buttonSprite:Sprite = button as Sprite;
			
			buttonSprite.mouseEnabled = buttonSprite.mouseChildren = value;
			buttonSprite.alpha = value ? 1 : .5;
		}
		
		public function showReplySuccess():void
		{
			SdgAlertChrome.show("Your message has been sent.", "Message Sent");
		}
		
		public function showReportSuccess():void
		{
			ModeratorAlertChrome.show("Thank you for reporting this message", "Message Reported");
		}
		
		public function handleUpdateError(actionType:int):void
		{
			var errorMessage:String;
			if (actionType == MessageBoardServerEvent.ACTION_TYPE_DELETE)
			{
				errorMessage = "Delete Message Error";
			}
			else if (actionType == MessageBoardServerEvent.ACTION_TYPE_REPORT)
			{
				errorMessage = "Report Message Error";
			}
			
			SdgAlertChrome.show(errorMessage, "Time Out");
		}
		
		public function handleMessageListError():void
		{
			SdgAlertChrome.show("Message List Error", "Time Out");
		}
		
		private function setPage(value:int):void
		{
			var messagesPerPage:int = NUM_ROWS * NUM_COLUMNS;
			var messages:ArrayCollection = _model.messages;
			var maxPage:int = Math.max(0, Math.ceil(messages.length / messagesPerPage) - 1);
			
			if (value < 0 || value > maxPage)
			{
				if (_page < 0)
					value = 0;
				else if (_page > maxPage)
					value = maxPage;
				else
					return;
			}
			
			_page = value;
			
			_leftButton.visible = _page > 0;
			_rightButton.visible = _page < maxPage; 
			
			_pageNumTF.text = "PAGE " + (_page + 1) + "/" + (maxPage + 1);
			_pageNumTF.x = width/2 - _pageNumTF.width/2;
			
			if (_messageContainer != null)
			{
				closeMessages();
				removeChild(_messageContainer);
			}
			setSelectedMessage(null);
			
			_messageContainer = new Sprite();
			addChildAt(_messageContainer, 1);
			_messageContainer.x = 70;
			_messageContainer.y = 150;
			
			var index:int;
			var messageView:TurfMessageView;
			var startIndex:int = _page * messagesPerPage;
			var endIndex:int = startIndex + messagesPerPage;
			for (index = startIndex; index < endIndex && index < messages.length; index++)
			{
				messageView = new TurfMessageView(messages[index]);
				_messageContainer.addChild(messageView);
				messageView.y = Math.floor((index % messagesPerPage) / NUM_COLUMNS) * 205;
				messageView.x = (index % NUM_COLUMNS) * 200;
				messageView.buttonMode = true;
				
				messageView.addEventListener(MouseEvent.CLICK, onMessageClick, false, 0, true);
				messageView.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
				messageView.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
			}
		}
		
		private function closeMessages():void
		{
			var index:int;
			var messageView:TurfMessageView;
			
			for (index = 0; index < _messageContainer.numChildren; index++)
			{
				messageView = _messageContainer.getChildAt(index) as TurfMessageView;
				messageView.removeEventListener(MouseEvent.CLICK, onMessageClick);
				messageView.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				messageView.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				messageView.destroy();
			}
		}
		
		private function onMouseOver(event:MouseEvent):void
		{
			var turfMessage:TurfMessageView = event.currentTarget as TurfMessageView;
			turfMessage.setHighlight(true);
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			var turfMessage:TurfMessageView = event.currentTarget as TurfMessageView;
			if (_selectedMessage == turfMessage) return;
			turfMessage.setHighlight(false);
		}
		
		private function onMessageClick(event:MouseEvent):void
		{
			setSelectedMessage(event.currentTarget as TurfMessageView);
		}
		
		private function setSelectedMessage(value:TurfMessageView):void
		{
			if (_selectedMessage != null)
			{
				if (_selectedMessage == value) return;
				
				_selectedMessage.setHighlight(false);
			}
			
			_selectedMessage = value;
			
			if (_selectedMessage != null)
				_selectedMessage.setHighlight(true);
			
			updateButtons();
		}
		
		private function onMessageListUpdated(event:MessageBoardEvent):void
		{
			setPage(0);
		}
		
		private function onMessageDeleted(event:MessageBoardEvent):void
		{
			setPage(_page);
		}
		
		public function close():void
		{
			_model.removeEventListener(MessageBoardEvent.MESSAGE_LIST_UPDATED, onMessageListUpdated);
			_model.removeEventListener(MessageBoardEvent.MESSAGE_DELETED, onMessageDeleted);
			
			_goHomeTurfButton.removeEventListener(MouseEvent.CLICK, onHomeTurfButtonClick);
			_goHomeTurfButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			_goHomeTurfButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseButtonClick);
			
			_addMessageButton.removeEventListener(MouseEvent.CLICK, onAddMessageClick);
			
			_reportButton.removeEventListener(MouseEvent.CLICK, onReportClick);
			_reportButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			_reportButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			
			_deleteButton.removeEventListener(MouseEvent.CLICK, onDeleteClick);
			_deleteButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			_deleteButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			
			_leftButton.removeEventListener(MouseEvent.CLICK, onArrowClick);
			
			_rightButton.removeEventListener(MouseEvent.CLICK, onArrowClick);
			
			_friendButton.removeEventListener(MouseEvent.CLICK, onFriendButtonClick);
			_friendButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			_friendButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			
			_replyButton.removeEventListener(MouseEvent.CLICK, onReplyClick);
			_replyButton.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			_replyButton.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			
			closeMessages();
		}
	}
}
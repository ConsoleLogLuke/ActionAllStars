package com.sdg.messageBoard.views
{
	import com.sdg.components.controls.MVPAlert;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.messageBoard.events.MessageBoardEvent;
	import com.sdg.messageBoard.models.AddMessageModel;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.QuickLoader;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.ItemListWindow;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import mx.events.CloseEvent;
	import mx.utils.StringUtil;

	public class AddMessageView extends Sprite
	{
		private static const NUM_COLUMNS:int = 5;

		private var _model:AddMessageModel;
		private var _turfMessageView:TurfMessageView;
		private var _postItButton:DisplayObject;
		private var _selectedColorButton:ColorButton;
		private var _selectedStickerButton:StickerButton;
		private var _closeButton:DisplayObject;

		public function AddMessageView(model:AddMessageModel)
		{
			super();

			_model = model;

			var background:QuickLoader = new QuickLoader("swfs/turfBuilder/msgBoard/NotePad.swf", onBGComplete);

			_closeButton = new QuickLoader("swfs/turfBuilder/msgBoard/ButtonClose.swf", onCloseButtonComplete);

			_turfMessageView = new TurfMessageView(_model.turfMessage, false);
			_turfMessageView.setInputMode(true);
			_turfMessageView.scaleX = _turfMessageView.scaleY = 1.8;
			_turfMessageView.x = 425;
			_turfMessageView.y = 125;
			addChild(_turfMessageView);

			var index:int;
			var optionButton:MessageOptionButton;
			var colors:Array = ColorButton.colorMap;

			for (index = 0; index < colors.length; index++)
			{
				optionButton = new ColorButton(index, 50, 50);
				optionButton.x = index * 65 + 50;
				optionButton.y = 220;
				addChild(optionButton);
				optionButton.addEventListener(MouseEvent.CLICK, onColorClick, false, 0, true);
				optionButton.addEventListener(MouseEvent.MOUSE_OVER, onOptionMouseOver, false, 0, true);
				optionButton.addEventListener(MouseEvent.MOUSE_OUT, onOptionMouseOut, false, 0, true);

				if (_selectedColorButton == null)
				{
					selectColor(optionButton as ColorButton);
				}
			}

//			var stickerWindow:ItemListWindow = new ItemListWindow(340, 185, 5, 20, 10);
//
//			var stickerCollection:DisplayObjectCollection = new DisplayObjectCollection();

			for (index = 0; index < StickerButton.NUM_STICKERS; index++)
			{
				optionButton = new StickerButton(index, 45, 45);
				optionButton.x = index % NUM_COLUMNS * 55 + 50;
				optionButton.y = Math.floor(index / NUM_COLUMNS) * 55 + 350;
//				stickerCollection.push(optionButton);
				addChild(optionButton);
				optionButton.addEventListener(MouseEvent.CLICK, onStickerClick, false, 0, true);
				optionButton.addEventListener(MouseEvent.MOUSE_OVER, onOptionMouseOver, false, 0, true);
				optionButton.addEventListener(MouseEvent.MOUSE_OUT, onOptionMouseOut, false, 0, true);

				if (_selectedStickerButton == null)
				{
					selectSticker(optionButton as StickerButton);
				}
			}

//			stickerWindow.items = stickerCollection;
//			stickerWindow.x = 34;
//			stickerWindow.y = 334;
//			addChild(stickerWindow);

			_postItButton = new QuickLoader("swfs/turfBuilder/msgBoard/ButtonPostIt.swf", onPostItButtonComplete);

			function onBGComplete():void
			{
				addChildAt(background.content, 0);
			}
		}

		public function handleChatFilterError(badWords:Array):void
		{
			SdgAlertChrome.show("Sorry we don't know that word! Try again.", "Time Out", errorAlertCloseHandler);
			_turfMessageView.showFilterMessage(badWords);
		}

		public function handlePostError():void
		{
			SdgAlertChrome.show("Post Message Error", "Time Out", errorAlertCloseHandler);
		}

		private function errorAlertCloseHandler(event:CloseEvent):void
		{
			_turfMessageView.setInputMode(true);
			mouseEnabled = mouseChildren = true;
		}

		public function close():void
		{
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseButtonClick);
			_postItButton.removeEventListener(MouseEvent.CLICK, onPostItClick);
		}

		private function onCloseButtonComplete():void
		{
			_closeButton = QuickLoader(_closeButton).content;
			_closeButton.x = 755;
			_closeButton.y = 20;
			addChild(_closeButton);
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClick, false, 0, true);
		}

		private function onCloseButtonClick(event:MouseEvent):void
		{
			dispatchEvent(new MessageBoardEvent(MessageBoardEvent.CLOSE_ADD_MESSAGE));
		}

		private function onPostItButtonComplete():void
		{
			_postItButton = QuickLoader(_postItButton).content;
			_postItButton.x = 470;
			_postItButton.y = 460;
			addChild(_postItButton);
			_postItButton.addEventListener(MouseEvent.CLICK, onPostItClick, false, 0, true);
		}

		private function onPostItClick(event:MouseEvent):void
		{
			postMessage();
		}

		private function postMessage():void
		{
			var trimmedMessage:String = StringUtil.trim(_turfMessageView.message);
			if (trimmedMessage.length == 0) return;
			_model.turfMessage.message = trimmedMessage;
			_turfMessageView.setInputMode(false);
			mouseEnabled = mouseChildren = false;

			var event:MessageBoardEvent = new MessageBoardEvent(MessageBoardEvent.POST_IT);
			event.turfMessage = _model.turfMessage;
			dispatchEvent(event);
		}

		private function selectColor(button:ColorButton):void
		{
			if (button == _selectedColorButton) return;

			if (_selectedColorButton != null)
				_selectedColorButton.setHighlight(false);

			_selectedColorButton = button;
			_selectedColorButton.setHighlight(true);
			_turfMessageView.turfMessage.bgId = _selectedColorButton.value;
		}

		private function selectSticker(button:StickerButton):void
		{
			if (button == _selectedStickerButton) return;

			if (_selectedStickerButton != null)
				_selectedStickerButton.setHighlight(false);

			_selectedStickerButton = button;
			_selectedStickerButton.setHighlight(true);
			_turfMessageView.turfMessage.stickerId = _selectedStickerButton.value;
		}

		private function onOptionMouseOver(event:MouseEvent):void
		{
			var optionButton:MessageOptionButton = event.currentTarget as MessageOptionButton;
			optionButton.setHighlight(true);
		}

		private function onOptionMouseOut(event:MouseEvent):void
		{
			var optionButton:MessageOptionButton = event.currentTarget as MessageOptionButton;

			var selectedOption:MessageOptionButton;
			if (optionButton is ColorButton)
				selectedOption = _selectedColorButton;
			else if (optionButton is StickerButton)
				selectedOption = _selectedStickerButton;

			if (selectedOption == optionButton) return;

			optionButton.setHighlight(false);
		}

		private function isMVPMember(viewLinkId:int, clickLinkId:int):Boolean
		{
			var isMVP:Boolean = true;

			if (ModelLocator.getInstance().avatar.membershipStatus == MembershipStatus.MEMBER)
			{
				LoggingUtil.sendClickLogging(viewLinkId);
				var mvpAlert:MVPAlert =	MVPAlert.show("You need to be an MVP member to decorate your message.  Join right now and also unlock exclusive games, shopping, events, and missions.", "Join the Team!", onUpsellClose);
				mvpAlert.addButton("Become A Member", clickLinkId, 250);
				isMVP = false;
			}

			return isMVP;

			function onUpsellClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;

				if (identifier == clickLinkId)
					MainUtil.goToMVP(identifier);
			}
		}

		private function onColorClick(event:MouseEvent):void
		{
			if (isMVPMember(LoggingUtil.MVP_UPSELL_VIEW_MSG_BOARD_COLOR, LoggingUtil.MVP_UPSELL_CLICK_MSG_BOARD_COLOR))
			{
				LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_CHANGE_COLOR_MVP);
				selectColor(event.currentTarget as ColorButton);
			}
		}

		private function onStickerClick(event:MouseEvent):void
		{
			if (isMVPMember(LoggingUtil.MVP_UPSELL_VIEW_MSG_BOARD_STICKER, LoggingUtil.MVP_UPSELL_CLICK_MSG_BOARD_STICKER))
			{
				LoggingUtil.sendClickLogging(LoggingUtil.MSG_BOARD_CHANGE_STICKER_MVP);
				selectSticker(event.currentTarget as StickerButton);
			}
		}
	}
}

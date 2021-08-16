package com.sdg.ui
{
	import com.sdg.controls.AASCloseButton;
	import com.sdg.display.AlignType;
	import com.sdg.display.Box;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.Container;
	import com.sdg.display.FillStyle;
	import com.sdg.display.Stack;
	import com.sdg.event.RoomSelectEvent;
	import com.sdg.event.UIDialogueEvent;
	import com.sdg.font.AASFonts;
	import com.sdg.model.RoomInfo;
	import com.sdg.trivia.TriviaRoomInfoBlock;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class UITriviaRoomSelect extends Container
	{
		private var _infoBlocks:Array;
		private var _closebtn:AASCloseButton;
		private var _roomInfoArray:Array;
		
		public function UITriviaRoomSelect(width:Number, roomInfoArray:Array)
		{
			super(width, 0, false);
			
			// Set initial vallues.
			_infoBlocks = [];
			_roomInfoArray = roomInfoArray;
			padding = 10;
			_paddingTop = 10;
			
			var padX:Number = _paddingLeft + _paddingRight;
			
			// Create title container and title.
			var titleStack:Stack = new Stack(AlignType.VERTICAL, 8);
			var genericContainer:Container;
			var logo:AASTriviaLogo = new AASTriviaLogo();
			logo.scaleX = logo.scaleY = 60 / logo.height;
			genericContainer = new Container();
			genericContainer.content = logo;
			titleStack.addContainer(genericContainer);
			var title:TextField = new TextField();
			title.autoSize = TextFieldAutoSize.CENTER;
			title.defaultTextFormat = new TextFormat(AASFonts.GILL_SANS, 14, 0xffffff, true);
			title.embedFonts = true;
			title.htmlText = 'Choose a room:';
			genericContainer = new Container();
			genericContainer.content = title;
			titleStack.addContainer(genericContainer);
			var titleContainer:Container = new Container();
			titleContainer.alignX = titleContainer.alignY = AlignType.MIDDLE;
			titleContainer.content = titleStack;
			
			var blockContainer:Container = new Container();
			var blockStack:Stack = new Stack(AlignType.VERTICAL, 4);
			var infoBlock:Container;
			var roomInfo:RoomInfo;
			var i:int = 0;
			var len:int = _roomInfoArray.length;
			for (i; i < len; i++)
			{
				roomInfo = _roomInfoArray[i] as RoomInfo;
				if (roomInfo != null)
				{
					infoBlock = new TriviaRoomInfoBlock(_width - padX, 20, roomInfo.name, roomInfo.numAvatars, roomInfo.maxAvatars);
					//infoBlock = new TriviaRoomFullBlock(200, 24);
					infoBlock.buttonMode = true;
					infoBlock.addEventListener(MouseEvent.MOUSE_OVER, _onInfoBlockOver);
					infoBlock.addEventListener(MouseEvent.MOUSE_OUT, _onInfoBlockOut);
					infoBlock.addEventListener(MouseEvent.CLICK, _onInfoBlockClick);
					blockStack.addContainer(infoBlock);
					_infoBlocks.push(infoBlock);
				}
			}
			blockContainer.content = blockStack;
			
			var mainStack:Stack = new Stack(AlignType.VERTICAL, 4);
			mainStack.equalizeSize = true;
			mainStack.addContainer(titleContainer);
			mainStack.addContainer(blockContainer);
			
			// Create close button.
			_closebtn = new AASCloseButton(16, 16);
			_closebtn.addEventListener(MouseEvent.CLICK, _onCloseClick);
			_addChild(_closebtn);
			
			// Create backing.
			backing = new Box();
			_backing.style = new BoxStyle(new FillStyle(0x000000, 0.8), 0, 0, 0, 12);
			
			content = mainStack;
		}
		
		override protected function _render():void
		{
			super._render();
			
			var padX:Number = _paddingLeft + _paddingRight;
			
			var i:int = 0;
			var len:int = _infoBlocks.length;
			for (i; i < len; i++)
			{
				var block:Sprite = _infoBlocks[i];
				block.width = _width - padX;
			}
			
			// Position the close button.
			if (_closebtn != null)
			{
				_closebtn.x = _width - _closebtn.width - 5;
				_closebtn.y = 5;
			}
		}
		
		private function _onCloseClick(e:MouseEvent):void
		{
			dispatchEvent(new UIDialogueEvent(UIDialogueEvent.CLOSE));
		}
		
		private function _onInfoBlockOver(e:MouseEvent):void
		{
			var infoBlock:Container = e.currentTarget as Container;
			infoBlock.filters = [new GlowFilter(0xffffff)];
		}
		private function _onInfoBlockOut(e:MouseEvent):void
		{
			var infoBlock:Container = e.currentTarget as Container;
			infoBlock.filters = [];
		}
		private function _onInfoBlockClick(e:MouseEvent):void
		{
			var infoBlock:Container = e.currentTarget as Container;
			
			// removing the click handler to prevent double click havoc
			infoBlock.removeEventListener(MouseEvent.CLICK, _onInfoBlockClick);
			
			var index:int = _infoBlocks.indexOf(infoBlock);
			if (index > -1)
			{
				var roomInfo:RoomInfo = _roomInfoArray[index] as RoomInfo;
				if (roomInfo != null) dispatchEvent(new RoomSelectEvent(RoomSelectEvent.SELECT, roomInfo));
			}
		}
		
	}
}
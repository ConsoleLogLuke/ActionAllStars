package com.sdg.trivia
{
	import com.sdg.display.AlignType;
	import com.sdg.display.Box;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.Container;
	import com.sdg.display.GradientFillStyle;
	import com.sdg.display.Stack;
	import com.sdg.font.AASFonts;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TriviaRoomInfoBlock extends Container
	{
		private var _roomName:String;
		private var _playerCount:int;
		private var _maxPlayers:int;
		private var _roomNameField:TextField;
		private var _playerCountField:TextField;
		private var _nameContainer:Container;
		private var _playerCountContainer:Container;
		private var _offStyle:BoxStyle;
		private var _overStyle:BoxStyle;
		private var _downStyle:BoxStyle;
		
		public function TriviaRoomInfoBlock(width:Number=0, height:Number=0, roomName:String = 'Trivia Room', playerCount:int = 0, maxPlayers:int = 0)
		{
			super(width, height, false);
			
			// Set initial values.
			_roomName = roomName;
			_playerCount = playerCount;
			_maxPlayers = maxPlayers;
			_offStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x1d5479, 0x1d5479, 0x08426a, 0x08426a], [1, 1, 1, 1], [1, 110, 130, 255], Math.PI/2), 0, 0, 0, 10);
			_overStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x9bcaf7, 0x4689bb], [1, 1], [1, 180], Math.PI/2), 0, 0, 0, 14);
			_downStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x4a98e5, 0x1a659d], [1, 1], [1, 180], Math.PI/2), 0, 0, 0, 14);
			_paddingLeft = _paddingRight = 10;
			_paddingTop = 2;
			
			// Create text fields.
			_roomNameField = new TextField();
			_roomNameField.autoSize = TextFieldAutoSize.LEFT;
			_roomNameField.defaultTextFormat = new TextFormat(AASFonts.GILL_SANS, 14, 0xffffff, true);
			_roomNameField.selectable = false;
			_roomNameField.mouseEnabled = false;
			_roomNameField.embedFonts = true;
			_roomNameField.text = _roomName;
			
			_playerCountField = new TextField();
			_playerCountField.autoSize = TextFieldAutoSize.LEFT;
			_playerCountField.defaultTextFormat = new TextFormat(AASFonts.GILL_SANS, 14, 0x5dc4ff, true);
			_playerCountField.selectable = false;
			_playerCountField.mouseEnabled = false;
			_playerCountField.embedFonts = true;
			_playerCountField.text = _playerCount + '/' + _maxPlayers;
			
			// Create containers.
			var textStack:Stack = new Stack();
			_nameContainer = new Container();
			_nameContainer.alignY = AlignType.MIDDLE;
			_nameContainer.content = _roomNameField;
			textStack.addContainer(_nameContainer);
			
			_playerCountContainer = new Container();
			_playerCountContainer.alignX = AlignType.RIGHT;
			_playerCountContainer.alignY = AlignType.MIDDLE;
			_playerCountContainer.content = _playerCountField;
			textStack.addContainer(_playerCountContainer);
			
			// Create backing.
			backing = new Box();
			_backing.style = _offStyle;
			
			content = textStack;
			
			_render();
		}
		
		override protected function _render():void
		{
			super._render();
			
			var padX:Number = _paddingLeft + _paddingRight;
			
			// Size the containers to the size of this container.
			_nameContainer.width = _width - padX - _playerCountContainer.width;
		}
	}
}
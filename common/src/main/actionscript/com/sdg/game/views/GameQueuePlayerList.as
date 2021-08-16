package com.sdg.game.views
{
	import com.sdg.controls.AASCloseButton;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.FillStyle;
	import com.sdg.utils.EmbeddedImages;
	import com.sdg.view.FluidView;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class GameQueuePlayerList extends FluidView
	{
		private static const _STROKE_FILTER:GlowFilter = new GlowFilter(0, 1, 4, 4, 50);
		
		private var _back:DisplayObject;
		private var _titleField:TextField;
		private var _usersField:TextField;
		private var _timeField:TextField;
		private var _userNames:Array;
		private var _margin:Number;
		private var _maxPlayers:int;
		private var _timePrefix:String;
		private var _timeSuffix:String;
		private var _timeValue:Number;
		private var _closeButton:AASCloseButton;
		
		public function GameQueuePlayerList(userNames:Array = null, maxPlayers:int = 4, width:Number = 400, height:Number = 200)
		{
			super(width, height);
			
			_margin = 20;
			_userNames = (userNames) ? userNames : [];
			_maxPlayers = Math.max(maxPlayers, 2);
			_timePrefix = 'Game starts in ';
			_timeSuffix = ' seconds';
			
			_back = new EmbeddedImages.popupPanel();
			
			_titleField = new TextField();
			_titleField.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffb447, true);
			_titleField.autoSize = TextFieldAutoSize.LEFT;
			_titleField.selectable = false;
			_titleField.embedFonts = true;
			_titleField.filters = [_STROKE_FILTER];
			_titleField.text = 'Game Queue';
			
			_usersField = new TextField();
			_usersField.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			_usersField.autoSize = TextFieldAutoSize.LEFT;
			_usersField.selectable = false;
			_usersField.multiline = true;
			_usersField.wordWrap = true;
			_usersField.embedFonts = true;
			
			_timeField = new TextField();
			_timeField.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffb447, true, null, null, null, null, TextFormatAlign.RIGHT);
			_timeField.autoSize = TextFieldAutoSize.RIGHT;
			_timeField.selectable = false;
			_timeField.embedFonts = true;
			_timeField.filters = [_STROKE_FILTER];
			
			_closeButton = new AASCloseButton(32, 32);
			_closeButton.offStyle = new BoxStyle(new FillStyle(0xfcbf00, 1), 0, 1, 3, 32);
			_closeButton.overStyle = new BoxStyle(new FillStyle(0xff0000, 1), 0xffffff, 1, 3, 32);
			_closeButton.downStyle = new BoxStyle(new FillStyle(0xff0000, 1), 0xffffff, 1, 3, 32);
			_closeButton.labelFormat = new TextFormat('GillSans', 20, 0, true);
			_closeButton.addEventListener(MouseEvent.ROLL_OVER, onCloseOver);
			_closeButton.addEventListener(MouseEvent.ROLL_OUT, onCloseOut);
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			
			// Add displays.
			addChild(_back);
			addChild(_titleField);
			addChild(_usersField);
			addChild(_timeField);
			addChild(_closeButton);
			
			renderUsersText();
			render();
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Cleanup.
			_closeButton.removeEventListener(MouseEvent.ROLL_OVER, onCloseOver);
			_closeButton.removeEventListener(MouseEvent.ROLL_OUT, onCloseOut);
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseClick);
		}
		
		public function addUserName(name:String):void
		{
			// Make sure name is not already in list.
			if (_userNames.indexOf(name) < 0) _userNames.push(name);
			renderUsersText();
		}
		
		public function removeUserName(name:String):void
		{
			// Remove name from list.
			var index:int = _userNames.indexOf(name);
			if (index > -1) _userNames.splice(index, 1);
			renderUsersText();
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_back.width = _width;
			_back.height = _height;
			
			renderTitle();
			
			_usersField.x = _margin;
			_usersField.y = _titleField.y + _titleField.height + 10;
			_usersField.width = _width - _margin * 2;
			_usersField.height = _height - _titleField.y - _titleField.height - 20;
			
			renderTimeField();
			
			_closeButton.x = _width - _closeButton.width + _closeButton.width / 3;
			_closeButton.y = -_closeButton.width / 3;
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function renderUsersText():void
		{
			var i:int = 0;
			var len:int = _userNames.length;
			var usersText:String = '';
			var usersFilledLength:int = 0;
			for (i; i < _maxPlayers; i++)
			{
				if (i < len)
				{
					usersText = usersText + String(i + 1) + '. ' + _userNames[i] + '\n';
					usersFilledLength = usersText.length;
				}
				else
				{
					usersText = usersText + String(i + 1) + '. Empty\n';
				}
			}
			
			_usersField.text = usersText;
			// Give empty slots of the user list a different text format.
			var format:TextFormat = _usersField.getTextFormat();
			format.color = 0x888888;
			if (usersFilledLength < usersText.length) _usersField.setTextFormat(format, Math.min(usersFilledLength, usersText.length - 1), usersText.length - 1);
		}
		
		private function renderTitle():void
		{
			_titleField.x = _margin;
			_titleField.y = _margin / 2;
		}
		
		private function renderTimeField():void
		{
			_timeField.x = _width - _timeField.width - _margin;
			_timeField.y = _height - _timeField.height - _margin / 2;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get title():String
		{
			return _titleField.text;
		}
		public function set title(value:String):void
		{
			_titleField.text = value;
			renderTitle();
		}
		
		public function get userNames():Array
		{
			return _userNames;
		}
		public function set userNames(value:Array):void
		{
			_userNames = value;
			renderUsersText();
		}
		
		public function get timeValue():Number
		{
			return _timeValue;
		}
		public function set timeValue(value:Number):void
		{
			// Prevent negatives.
			value = Math.max(value, 0);
			if (value == _timeValue) return;
			_timeValue = value;
			_timeField.text = _timePrefix + _timeValue + _timeSuffix;
			// Give time a different text format.
			var format:TextFormat = _timeField.defaultTextFormat;
			format.color = 0xffffff;
			_timeField.setTextFormat(format, _timePrefix.length, _timePrefix.length + _timeValue.toString().length);
			
			renderTimeField();
		}
		
		////////////////////
		// EVENT FUNCTIONS
		////////////////////
		
		private function onCloseOver(e:MouseEvent):void
		{
			_closeButton.labelFormat = new TextFormat('GillSans', 20, 0xffffff, true);
		}
		
		private function onCloseOut(e:MouseEvent):void
		{
			_closeButton.labelFormat = new TextFormat('GillSans', 20, 0, true);
		}
		
		private function onCloseClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
	}
}
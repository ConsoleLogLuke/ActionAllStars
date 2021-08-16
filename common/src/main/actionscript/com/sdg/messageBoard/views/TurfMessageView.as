package com.sdg.messageBoard.views
{
	import com.sdg.messageBoard.events.TurfMessageEvent;
	import com.sdg.messageBoard.models.TurfMessage;
	import com.sdg.model.Buddy;
	import com.sdg.net.QuickLoader;
	import com.sdg.utils.EmbeddedImages;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class TurfMessageView extends Sprite
	{
		private var _nameTF:TextField;
		private var _genderIcon:DisplayObject;
		private var _messageTF:TextField;
		private var _turfMessage:TurfMessage;
		private var _paper:DisplayObject;
		private var _sticker:DisplayObject;
		private var _paperContainer:Sprite;
		private var _invalidTextFormat:TextFormat;
		private var _validTextFormat:TextFormat;
		private var _highlighted:Boolean;
		
		public function TurfMessageView(turfMessage:TurfMessage, showPin:Boolean = true)
		{
			super();
			
			_turfMessage = turfMessage;

			var imageClass:Class;
			
			// bg
			_paper = new (EmbeddedImages.postIt)();
			_paperContainer = new Sprite();
			_paperContainer.addChild(_paper);
			_paperContainer.filters = [new GlowFilter(0x000000, 1, 4, 4, 10)];
			var shadowContainer:Sprite = new Sprite();
			shadowContainer.addChild(_paperContainer);
			addChild(shadowContainer);
			shadowContainer.filters = [new DropShadowFilter(20, 60, 0, .25)];
			setBGColor();
			
			var sender:Buddy = _turfMessage.sender;
			
			// gender icon
			imageClass = sender.gender == 1 ? EmbeddedImages.boyIcon : EmbeddedImages.girlIcon;
			_genderIcon = new imageClass();
			addChild(_genderIcon);
			_genderIcon.filters = [new GlowFilter(0x000000, 1, 4, 4, 10)];
			_genderIcon.y = 13;
			
			_nameTF = new TextField();
			_nameTF.embedFonts = true;
			_nameTF.defaultTextFormat = new TextFormat('EuroStyle', 14, 0x4c4936, true);
			_nameTF.autoSize = TextFieldAutoSize.LEFT;
			_nameTF.selectable = false;
			_nameTF.text = sender.name;
			_nameTF.x = 48;
			_nameTF.y = 16;
			addChild(_nameTF);
			_nameTF.mouseEnabled = false;
			
			// level stars 
			imageClass = EmbeddedImages.starIcon;
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = 0x000000;
			for (var i:int = 0; i < sender.level; i++)
			{
				var star:DisplayObject = new imageClass();
				addChild(star);
				star.x = 48 + (i * 13);
				star.y = 35;
				star.transform.colorTransform = colorTransform;
				star.alpha = .2;
				star.scaleX = star.scaleY = .8;
			}
			
			_invalidTextFormat = new TextFormat('EuroStyle', 12, 0xff0000);
			_validTextFormat = new TextFormat('EuroStyle', 12, 0x4c4936);
			
			// message
			var message:String = _turfMessage.message;
			_messageTF = new TextField();
			_messageTF.embedFonts = true;
			_messageTF.defaultTextFormat = _validTextFormat;
			_messageTF.restrict = "a-zA-Z0-9' !?,";
			_messageTF.maxChars = 120;
			
			_messageTF.borderColor = 0x4c4936;
			_messageTF.text = message;
			_messageTF.selectable = false;
			_messageTF.mouseEnabled = false;
			
			_messageTF.multiline = true;
			_messageTF.wordWrap = true;
			_messageTF.width = 140;
			_messageTF.height = 94;
			_messageTF.tabEnabled = false;
			_messageTF.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			addChild(_messageTF);
			_messageTF.x = 25;
			_messageTF.y = 55;
			_messageTF.addEventListener(Event.CHANGE, onChange, false, 0, true);
			
			// green tack
			if (showPin)
			{
				var greenTack:DisplayObject = new (EmbeddedImages.tack)();
				addChild(greenTack);
				greenTack.x = 68;
				greenTack.y = -27;
			}
			
			// sticker
			setSticker();
			
			_turfMessage.addEventListener(TurfMessageEvent.BG_ID_CHANGE, onBGChange, false, 0, true);
			_turfMessage.addEventListener(TurfMessageEvent.STICKER_ID_CHANGE, onStickerChange, false, 0, true);
		}
		
		private function onChange(event:Event):void
		{
			if (_messageTF.numLines > 6)
			{
				_messageTF.removeEventListener(Event.CHANGE, onChange);
				_messageTF.type = TextFieldType.DYNAMIC;
				
				while (_messageTF.numLines > 6)
				{
					_messageTF.text = _messageTF.text.slice(0, -1);
				}
				
				_messageTF.type = TextFieldType.INPUT;
				_messageTF.addEventListener(Event.CHANGE, onChange);
			}
		}
		
		public function setInputMode(value:Boolean):void
		{
			if (value)
			{
				_messageTF.type = TextFieldType.INPUT;
				
				//stage.focus = _messageTF;
			}
			else
			{
				_messageTF.type = TextFieldType.DYNAMIC;
			}
			
			_messageTF.border = _messageTF.selectable = _messageTF.mouseEnabled = value;
		}
		
		private	function onKeyDown(e:KeyboardEvent):void
		{
			// on key input make the text white again
			_messageTF.defaultTextFormat = _validTextFormat;
			_messageTF.setTextFormat(_validTextFormat);
		}
		
		private function onBGChange(event:TurfMessageEvent):void
		{
			setBGColor();
		}
		
		private function onStickerChange(event:TurfMessageEvent):void
		{
			setSticker();
		}
		
		private function setBGColor():void
		{
			var colorTransform:ColorTransform = new ColorTransform();
			if (_turfMessage.bgId != null)
			{
				colorTransform.color = ColorButton.colorMap[_turfMessage.bgId];
			}
			_paper.transform.colorTransform = colorTransform;
		}
		
		public function destroy():void
		{
			_messageTF.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_messageTF.removeEventListener(Event.CHANGE, onChange);
			_turfMessage.removeEventListener(TurfMessageEvent.BG_ID_CHANGE, onBGChange);
			_turfMessage.removeEventListener(TurfMessageEvent.STICKER_ID_CHANGE, onStickerChange);
		}
		
		private function setSticker():void
		{
			var stickerId:Object = _turfMessage.stickerId;
			
			if (_sticker != null)
			{
				removeChild(_sticker);
				_sticker = null;
			}
			
			if (stickerId != null && stickerId != 0)
			{
				_sticker = new QuickLoader("assets/swfs/turfBuilder/msgBoard/sticker" + stickerId + ".swf", onComplete, onError);
			}
			
			function onComplete():void
			{
				_sticker = QuickLoader(_sticker).content;
				var scale:Number = Math.min(45/_sticker.width, 45/_sticker.height);
				_sticker.scaleX = _sticker.scaleY = scale;
				addChild(_sticker);
				_sticker.x = 130 - _sticker.width/2;
				_sticker.y = 172 - _sticker.height/2;
			}
			
			function onError():void
			{
				_sticker = null;
			}
		}
		
		public function get turfMessage():TurfMessage
		{
			return _turfMessage;
		}
		
		public function get message():String
		{
			return _messageTF.text;
		}
		
		public function showFilterMessage(badWords:Array):void
		{
			_messageTF.text = _turfMessage.message;
			
			var len:int = badWords.length;
			var badWord:String;
			var startIndex:int;
			for (var i:int = 0; i < len; i += 2)
			{
				// Determine bad word and it's start index.
				badWord = badWords[i];
				startIndex = badWords[i + 1];
				
				_messageTF.setTextFormat(_invalidTextFormat, startIndex, startIndex + badWord.length);
			}
			
			_messageTF.appendText(' ');
			_messageTF.setSelection(_messageTF.text.length, _messageTF.text.length);
			_messageTF.setTextFormat(_validTextFormat, _messageTF.text.length - 1);
		}
		
		public function setHighlight(value:Boolean):void
		{
			if (_highlighted == value) return;
			
			_highlighted = value;
			var bgFilter:Array = _paperContainer.filters;
			if (_highlighted)
			{
				bgFilter.push(new GlowFilter(0xffffff, 1, 10, 10, 10));
			}
			else
			{
				bgFilter.pop();
			}
			_paperContainer.filters = bgFilter;
		}
	}
}
package com.sdg.components.controls
{
	import com.sdg.graphics.Point;
	import com.sdg.net.QuickLoader;
	import com.sdg.utils.EmbeddedImages;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class SdgAlertChrome extends UIComponent
	{
		protected var _buttonContainer:Sprite;
		protected var _background:DisplayObject;
		protected var _icon:DisplayObject;
		protected var _titleTF:TextField;
		protected var _messageTF:TextField;
		protected var _buttons:Array;
		protected var _customButtons:Array;
		
		public function SdgAlertChrome(message:String, title:String, okButton:Boolean, width:int, height:int,
										eCode:String = null, iconUrl:String = "assets/swfs/alert/popup_exclamation.swf")
		{
			super();
			this.width = width;
			this.height = height;
			
			_background = new (EmbeddedImages.popupPanel)();
			addChildAt(_background, 0);
			scaleBG();
			
			if (iconUrl != null)
				_icon = new QuickLoader(iconUrl, onIconComplete);
			
			_titleTF = new TextField();
			_titleTF.embedFonts = true;
			_titleTF.defaultTextFormat = new TextFormat('EuroStyle', 28, 0xfdc000, true);
			_titleTF.autoSize = TextFieldAutoSize.LEFT;
			_titleTF.selectable = false;
			_titleTF.text = title;
			addChild(_titleTF);
			_titleTF.x = width/2 - _titleTF.width/2;
			_titleTF.y = 30;
			_titleTF.filters = [new GlowFilter(0x000000, 1, 5, 5, 10)];
			
			_messageTF = new TextField();
			_messageTF.embedFonts = true;
			_messageTF.defaultTextFormat = new TextFormat('EuroStyle', 15, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
			_messageTF.autoSize = TextFieldAutoSize.CENTER;
			_messageTF.selectable = false;
			_messageTF.text = message;
			_messageTF.multiline = true;
			_messageTF.wordWrap = true;
			_messageTF.width = width - 20;
			addChild(_messageTF);
			_messageTF.x = width/2 - _messageTF.width/2;
			_messageTF.y = height/2 - _messageTF.height/2;
			_messageTF.filters = [new GlowFilter(0x000000, 1, 5, 5, 10)];
			
			if (eCode)
			//if (true)
			{
				var errorTF:TextField = new TextField();
				errorTF.embedFonts = true;
				errorTF.defaultTextFormat = new TextFormat('EuroStyle', 7, 0x222422, true, null, null, null, null, TextFormatAlign.RIGHT);
				errorTF.autoSize = TextFieldAutoSize.RIGHT;
				errorTF.selectable = false;
				errorTF.text = eCode;
				//errorTF.text = "12-405";
				errorTF.multiline = true;
				errorTF.wordWrap = true;
				errorTF.x = width-errorTF.width-1;
				errorTF.y = height-errorTF.height-1;
				//errorTF.x = 50;
				//errorTF.y = 50;
				addChild(errorTF);
			}
			
			_buttonContainer = new Sprite();
			addChild(_buttonContainer);
			if (okButton)
				addButton("OK", 1);
			
			function onIconComplete():void
			{
				_icon = QuickLoader(_icon).content;
				addChild(_icon);
				_icon.x = -_icon.width/8;
				_icon.y = -20;
			}
		}
		
		private function scaleBG():void
		{
			_background.scaleX *= width/_background.width;
			_background.scaleY *= height/_background.height;
		}
		
		public function addCustomButton(button:DisplayObject, identifier:int, location:Point = null):void
		{
			if (location)
			{
				button.x = location.x;
				button.y = location.y;
				addChild(button);
			}
			else
			{
				_buttonContainer.addChild(button);
				positionButtons();
			}
			
			if (_customButtons == null) _customButtons = new Array();
			_customButtons.push(button);
			
			button.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			function onButtonClick(event:MouseEvent):void
			{
				close(identifier);
			}
		}
		
		public function addButton(label:String, identifier:int, location:Point = null):DisplayObject
		{
			var button:Sprite = new Sprite();
			
			var buttonBG:DisplayObject = new EmbeddedImages.popupGreenButton();
			button.addChild(buttonBG);
			button.graphics.drawRect(0, 0, buttonBG.width, buttonBG.height);
			
			var buttonLabel:TextField = new TextField();
			buttonLabel.embedFonts = true;
			buttonLabel.defaultTextFormat = new TextFormat('EuroStyle', 16, 0xffffff, true);
			buttonLabel.autoSize = TextFieldAutoSize.LEFT;
			buttonLabel.selectable = false;
			buttonLabel.text = label;
			button.addChild(buttonLabel);
			buttonLabel.mouseEnabled = false;
			buttonLabel.filters = [new GlowFilter(0x000000, 1, 5, 5, 10)];
			
			buttonLabel.x = button.width/2 - buttonLabel.width/2;
			buttonLabel.y = button.height/2 - buttonLabel.height/2 + 2;
			
			if (location)
			{
				button.x = location.x;
				button.y = location.y;
				addChild(button);
			}
			else
			{
				_buttonContainer.addChild(button);
				positionButtons();
			}
			
			if (_buttons == null) _buttons = new Array();
			_buttons.push(button);
		
			button.addEventListener(MouseEvent.CLICK, onButtonClick);
			button.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			
			return button;
			
			function onButtonMouseOver(event:MouseEvent):void
			{
				buttonLabel.textColor = 0xfdc000;
			}
			
			function onButtonMouseOut(event:MouseEvent):void
			{
				buttonLabel.textColor = 0xffffff;
			}
			
			function onButtonClick(event:MouseEvent):void
			{
				close(identifier);
			}
		}
		
		private function positionButtons():void
		{
			var curr:DisplayObject;
			var xPos:int = 0;
			
			for (var i:int = 0; i < _buttonContainer.numChildren; i++)
			{
				curr = _buttonContainer.getChildAt(i);
				curr.x = xPos;
				xPos += curr.width + 10;
				
				curr.y = _buttonContainer.height/2 - curr.height/2;
			}
			
			_buttonContainer.x = width/2 - _buttonContainer.width/2;
			_buttonContainer.y = height - _buttonContainer.height - 15;
		}
		
		public function show(closeHandler:Function = null, parent:Sprite = null, modal:Boolean = true, center:Boolean = true):void
		{
			if (closeHandler != null)
				addEventListener(CloseEvent.CLOSE, onClose);
			
			visible = true;
			
			modal = false;
			if (modal)
			{
				MainUtil.showModalDialog(null, null, this);
			}
			else
			{
				PopUpManager.addPopUp(this, parent ? parent : Sprite(Application.application), modal);
				if (center)
					PopUpManager.centerPopUp(this);
			}
			
			function onClose(event:CloseEvent):void
			{
				removeEventListener(CloseEvent.CLOSE, onClose);
				closeHandler(event);
			}
		}
		
		/**
		 * Static show method.
		 */
		public static function show(message:String, title:String, closeHandler:Function = null, parent:Sprite = null, 
									modal:Boolean = true, okButton:Boolean = true, width:int = 430, height:int = 200, eCode:String = null):SdgAlertChrome
		{
			var alert:SdgAlertChrome = new SdgAlertChrome(message, title, okButton, width, height, eCode);
			
			alert.show(closeHandler, parent, modal);
			return alert;
		}

		public function close(closeDetail:int = -1):void
		{
			var button:DisplayObject;
			if (_buttons != null)
			{
				for each (button in _buttons)
				{
					button.removeEventListener(MouseEvent.CLICK, arguments.callee);
					button.removeEventListener(MouseEvent.MOUSE_OVER, arguments.callee);
					button.removeEventListener(MouseEvent.MOUSE_OUT, arguments.callee);
				}
				_buttons = null;
			}
			
			if (_customButtons != null)
			{
				for each (button in _customButtons)
				{
					button.removeEventListener(MouseEvent.CLICK, arguments.callee);
				}
				_customButtons = null;
			}
			
			var event:CloseEvent = new CloseEvent(CloseEvent.CLOSE, false, true, closeDetail);
			
			dispatchEvent(event);

			if (!event.isDefaultPrevented())
			{
				visible = false;
				PopUpManager.removePopUp(this);
			}
		}
	}
}
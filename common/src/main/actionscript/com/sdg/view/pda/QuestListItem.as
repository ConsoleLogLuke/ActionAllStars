package com.sdg.view.pda
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class QuestListItem extends Sprite
	{
		protected var _backingColor:uint;
		protected var _questTitle:String;
		protected var _completed:Boolean;
		protected var _isMandatory:Boolean;
		protected var _width:Number;
		protected var _height:Number;
		protected var _questId:uint;
		
		protected var _titleField:TextField;
		protected var _backing:Sprite;
		protected var _checkBox:CheckBox;
		protected var _importantIcon:DisplayObject;
		
		public function QuestListItem(questId:uint, title:String, completed:Boolean = false, isMandatory:Boolean = false)
		{
			super();
			
			// Set default values.
			_width = 120;
			_height = 18;
			_backingColor = 0xffffff;
			_questTitle = title;
			_completed = completed;
			_isMandatory = isMandatory;
			_questId = questId;
			
			// Create backing.
			_backing = new Sprite();
			addChild(_backing);
			
			// Create check box.
			_checkBox = new CheckBox();
			addChild(_checkBox);
			
			// Create title field.
			_titleField = new TextField();
			_titleField.autoSize = TextFieldAutoSize.LEFT;
			_titleField.selectable = false;
			_titleField.mouseEnabled = false;
			addChild(_titleField);
			
			// Load important icon.
			var url:String = 'assets/swfs/importantIcon.swf';
			var request:URLRequest = new URLRequest(url);
			var importantIconLoader:Loader = new Loader();
			importantIconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImportantImageComplete);
			importantIconLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImportantImageError);
			importantIconLoader.load(request);
			
			render();
			
			function onImportantImageComplete(e:Event):void
			{
				// Remove event listeners.
				importantIconLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImportantImageComplete);
				importantIconLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImportantImageError);
				
				// Set image reference.
				_importantIcon = importantIconLoader.content;
				addChild(_importantIcon);
				
				render();
			}
			
			function onImportantImageError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				importantIconLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImportantImageComplete);
				importantIconLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImportantImageError);
			}
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		protected function render():void
		{
			var spacing:Number = 10;
			
			// Draw backing.
			_backing.graphics.clear();
			_backing.graphics.beginFill(_backingColor);
			_backing.graphics.drawRect(0, 0, _width, _height);
			
			// Position check box.
			_checkBox.width = _checkBox.height = _height - 12;
			_checkBox.x = spacing;
			_checkBox.y = _height / 2 - _checkBox.height / 2;
			_checkBox.isChecked = _completed;
			
			// Excalamtion.
			if (_importantIcon != null)
			{
				_importantIcon.width = _importantIcon.height = Math.floor(Math.min(_width, _height) - spacing);
				_importantIcon.x = _width - _importantIcon.width - spacing;
				_importantIcon.y = Math.floor(_height / 2 - _importantIcon.height / 2);
				_importantIcon.visible = _isMandatory;
			}
			
			// Draw text field.
			_titleField.text = _questTitle;
			_titleField.width = _width - ((_importantIcon != null) ? _importantIcon.width : 0) - _checkBox.width - spacing * 4;
			_titleField.x = _checkBox.x + _checkBox.width + spacing;
			_titleField.y = _height / 2 - _titleField.height / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get questId():uint
		{
			return _questId;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		public function get backingColor():uint
		{
			return _backingColor;
		}
		public function set backingColor(value:uint):void
		{
			if (value == _backingColor) return;
			_backingColor = value;
			render();
		}
		
		public function get questTitle():String
		{
			return _questTitle;
		}
		public function set questTitle(value:String):void
		{
			if (value == _questTitle) return;
			_questTitle = value;
			render();
		}
		
		public function get titleFormat():TextFormat
		{
			return _titleField.defaultTextFormat;
		}
		public function set titleFormat(value:TextFormat):void
		{
			_titleField.defaultTextFormat = value;
			render();
		}
		
		public function set embedFonts(value:Boolean):void
		{
			_titleField.embedFonts = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
	}
}
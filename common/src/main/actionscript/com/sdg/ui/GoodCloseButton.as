package com.sdg.ui
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class GoodCloseButton extends InteractiveSoundMaker
	{
		protected var _x:TextField;
		protected var _labelField:TextField;
		protected var _circW:Number;
		protected var _circH:Number;
		protected var _showLabel:Boolean;
		protected var _label:String;
		protected var _format:TextFormat;
		
		public function GoodCloseButton(label:String = 'Close')
		{
			super();
			
			_circW = 20;
			_circH = 20;
			_showLabel = false;
			_label = label;
			_format = new TextFormat('EuroStyle', 12, 0xffffff, true);
			
			_x = new TextField();
			_x.embedFonts = true;
			_x.defaultTextFormat = _format;
			_x.text = 'X';
			_x.autoSize = TextFieldAutoSize.LEFT;
			_x.selectable = false;
			_x.mouseEnabled = false;
			addChild(_x);
			
			_labelField = new TextField();
			_labelField.embedFonts = true;
			_labelField.defaultTextFormat = _format;
			_labelField.autoSize = TextFieldAutoSize.LEFT;
			_labelField.selectable = false;
			_labelField.mouseEnabled = false;
			_labelField.text = _label;
			addChild(_labelField);
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			render();
		}
		
		protected function render():void
		{
			graphics.clear();
			graphics.beginFill(0x333333);
			graphics.lineStyle(2, 0xffffff);
			graphics.drawEllipse(0, 0, _circW, _circH);
			graphics.endFill();
			
			_x.x = _circW / 2 - _x.width / 2;
			_x.y = _circH / 2 - _x.height / 2;
			
			if (_showLabel == true)
			{
				_labelField.x = -_labelField.width - 5;
				_labelField.y = _circH / 2 - _labelField.height / 2;
				var labelBounds:Rectangle = _labelField.getBounds(this);
				
				graphics.beginFill(0x333333);
				graphics.lineStyle(2, 0xffffff);
				graphics.drawRoundRect(labelBounds.x - 5, 0, _circW + labelBounds.width + 10, _circH, _circW, _circH);
				
				_labelField.visible = true;
			}
			else
			{
				_labelField.visible = false;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _circW;
		}
		
		override public function get height():Number
		{
			return _circH;
		}
		
		public function get useEmbededFonts():Boolean
		{
			return _labelField.embedFonts;
		}
		
		public function set useEmbededFonts(value:Boolean):void
		{
			_labelField.embedFonts = _x.embedFonts = value;
		}
		
		public function get textFormat():TextFormat
		{
			return _format;
		}
		public function set textFormat(value:TextFormat):void
		{
			_format = value;
			_labelField.defaultTextFormat = _format;
			_x.defaultTextFormat = _format;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onRollOver(e:MouseEvent):void
		{
			_showLabel = true;
			render();
			
			if (_overSound != null) _overSound.play();
		}
		
		private function onRollOut(e:MouseEvent):void
		{
			_showLabel = false;
			render();
			
			if (_outSound != null) _outSound.play();
		}
		
	}
}
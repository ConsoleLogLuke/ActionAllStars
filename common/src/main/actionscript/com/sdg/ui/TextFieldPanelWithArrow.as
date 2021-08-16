package com.sdg.ui
{
	import com.sdg.audio.EmbeddedAudio;
	import com.sdg.view.FluidView;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TextFieldPanelWithArrow extends FluidView
	{
		private var _back:Sprite;
		private var _field:TextField;
		private var _arrow:MovieClip;
		private var _value:String;
		private var _useArrow:Boolean;
		private var _overSound:Sound;
		
		public function TextFieldPanelWithArrow(width:Number, height:Number)
		{
			_useArrow = true;
			_overSound = new EmbeddedAudio.OverSound();
			
			_back = new Sprite();
			
			_field = new TextField();
			_field.defaultTextFormat = new TextFormat('EuroStyle', 16, 0xffffff, true);
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.selectable = false;
			_field.mouseEnabled = false;
			_field.embedFonts = true;
			_field.filters = [new GlowFilter(0, 1, 4, 4, 10)];
			
			_arrow = new ArrowButtonYellow();
			
			buttonMode = true;
			
			super(width, height);
			
			render();
			
			// Add listeners.
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			
			// Add displays.
			addChild(_back);
			addChild(_field);
			addChild(_arrow);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Remove listeners.
			removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			
			// Remove displays.
			removeChild(_back);
			removeChild(_field);
			removeChild(_arrow);
			
			// Remove references.
			_overSound = null;
			_field = null;
			_arrow = null;
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			var corner:Number = Math.min(_width, _height);
			
			_back.graphics.clear();
			_back.graphics.beginFill(0xffffff, 0.2);
			_back.graphics.drawRoundRect(0, 0, _width, _height, corner, corner);
			
			_arrow.width = _arrow.height = corner - 10;
			_arrow.x = _width - (_arrow.width / 2) - 5;
			_arrow.y = _arrow.width / 2 + 5;
			
			_field.x = _width / 2 - _field.width / 2;
			_field.y = _height / 2 - _field.height / 2;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get value():String
		{
			return _value;
		}
		public function set value(v:String):void
		{
			if (v == _value) return;
			_value = v;
			_field.text = _value;
			render();
		}
		
		public function get arrowRotation():Number
		{
			return _arrow.rotation;
		}
		public function set arrowRotation(value:Number):void
		{
			_arrow.rotation = value;
		}
		
		public function get useArrow():Boolean
		{
			return _useArrow;
		}
		public function set useArrow(value:Boolean):void
		{
			_useArrow = value;
			_arrow.visible = _useArrow;
			buttonMode = _useArrow;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onRollOver(e:MouseEvent):void
		{
			if (!_useArrow) return;
			
			_arrow.gotoAndStop(2);
			
			_overSound.play();
			
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			function onRollOut(e:MouseEvent):void
			{
				removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				if (_arrow) _arrow.gotoAndStop(1);
			}
		}
		
	}
}
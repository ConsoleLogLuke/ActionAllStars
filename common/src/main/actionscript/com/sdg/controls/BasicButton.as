package com.sdg.controls
{
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.display.AlignType;
	import com.sdg.display.Box;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.Container;
	import com.sdg.display.FillStyle;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BasicButton extends Container
	{
		protected var _label:TextField;
		protected var _offStyle:BoxStyle;
		protected var _overStyle:BoxStyle;
		protected var _downStyle:BoxStyle;
		protected var _buttonBacking:Box;
		protected var _labelFormat:TextFormat;
		protected var _embedFonts:Boolean;
		
		public function BasicButton(label:String, width:Number=0, height:Number=0, style:IButtonStyle = null)
		{
			super(width, height, false);
			
			// Set initial values.
			_embedFonts = false;
			buttonMode = true;
			if (style == null)
			{
				_offStyle = new BoxStyle(new FillStyle(0xffffff, 1), 0, 1, 1, 0);
				_overStyle = new BoxStyle(new FillStyle(0xdddddd, 1), 0, 1, 1, 0);
				_downStyle = new BoxStyle(new FillStyle(0xaaaaaa, 1), 0, 1, 1, 0);
			}
			else
			{
				_offStyle = style.offStyle;
				_overStyle = style.overStyle;
				_downStyle = style.downStyle;
			}
			
			_label = new TextField();
			_label.defaultTextFormat = new TextFormat('Arial', 12, 0, true);
			_label.autoSize = TextFieldAutoSize.CENTER;
			_label.selectable = false;
			_label.mouseEnabled = false;
			_label.text = label;
			_alignX = AlignType.MIDDLE;
			_alignY = AlignType.MIDDLE;
			content = _label;
			
			_buttonBacking = new Box(_width, _height);
			_buttonBacking.style = _offStyle;
			backing = _buttonBacking;
			
			// Add mouse interaction listeners.
			addEventListener(MouseEvent.MOUSE_OVER, _mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, _mouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, _mouseDown);
			addEventListener(MouseEvent.MOUSE_UP, _mouseUp);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get label():TextField
		{
			return _label;
		}
		
		public function get labelFormat():TextFormat
		{
			return _labelFormat;
		}
		public function set labelFormat(value:TextFormat):void
		{
			_labelFormat = value;
			_label.defaultTextFormat = _labelFormat;
			_label.text = _label.text;
			_render();
		}
		
		public function get embedFonts():Boolean
		{
			return _embedFonts;
		}
		public function set embedFonts(value:Boolean):void
		{
			_embedFonts = value;
			_label.embedFonts = _embedFonts;
		}
		
		public function get offStyle():BoxStyle
		{
			return _offStyle;
		}
		public function set offStyle(value:BoxStyle):void
		{
			_offStyle = value;
			_buttonBacking.style = _offStyle;
		}
		
		public function get overStyle():BoxStyle
		{
			return _overStyle;
		}
		public function set overStyle(value:BoxStyle):void
		{
			_overStyle = value;
		}
		
		public function get downStyle():BoxStyle
		{
			return _downStyle;
		}
		public function set downStyle(value:BoxStyle):void
		{
			_downStyle = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _mouseOver(e:MouseEvent):void
		{
			_buttonBacking.style = _overStyle;
		}
		private function _mouseOut(e:MouseEvent):void
		{
			_buttonBacking.style = _offStyle;
		}
		private function _mouseDown(e:MouseEvent):void
		{
			_buttonBacking.style = _downStyle;
		}
		private function _mouseUp(e:MouseEvent):void
		{
			_buttonBacking.style = _overStyle;
		}
		
	}
}
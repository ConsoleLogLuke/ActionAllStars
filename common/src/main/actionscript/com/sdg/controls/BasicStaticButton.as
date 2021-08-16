package com.sdg.controls
{
	import com.sdg.buttonformat.IButtonFormat;
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

	public class BasicStaticButton extends Container
	{
		protected var _labelOff:TextField;
		protected var _labelOver:TextField;
		protected var _labelDown:TextField;		
		protected var _offStyle:BoxStyle;
		protected var _overStyle:BoxStyle;
		protected var _downStyle:BoxStyle;
		protected var _offLabelFormat:TextFormat;
		protected var _overLabelFormat:TextFormat;
		protected var _downLabelFormat:TextFormat;
		protected var _buttonBacking:Box;
		protected var _labelFormat:TextFormat;
		protected var _embedFonts:Boolean;
		
		public function BasicStaticButton(label:String, width:Number, height:Number, style:IButtonStyle = null, embed:Boolean = false, format:IButtonFormat = null)
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
			
			if (format == null)
			{
				_offLabelFormat = new TextFormat('Arial', 12, 0, true)
				_overLabelFormat = new TextFormat('Arial', 12, 0, true)
				_downLabelFormat = new TextFormat('Arial', 12, 0, true)
			}
			else
			{
				_offLabelFormat = format.offFormat;
				_overLabelFormat = format.overFormat;
				_downLabelFormat = format.downFormat;
			}
			_labelOff = new TextField();
			_labelOver = new TextField();
			_labelDown = new TextField();
			
			_labelOff.embedFonts = embed;
			_labelOver.embedFonts = embed;
			_labelDown.embedFonts = embed;

			_labelOff.defaultTextFormat = _offLabelFormat;
			_labelOver.defaultTextFormat = _overLabelFormat;			
			_labelDown.defaultTextFormat = _downLabelFormat;					
			
			_labelOff.autoSize = TextFieldAutoSize.CENTER;
			_labelOver.autoSize = TextFieldAutoSize.CENTER;
			_labelDown.autoSize = TextFieldAutoSize.CENTER;
			
			_labelOff.selectable = false;
			_labelOver.selectable = false;
			_labelDown.selectable = false;
			
			_labelOff.mouseEnabled = false;
			_labelOver.mouseEnabled = false;
			_labelDown.mouseEnabled = false;
			
			_labelOff.text = label;
			_labelOver.text = label;
			_labelDown.text = label;
			
			_alignX = AlignType.MIDDLE;
			
			_alignY = AlignType.MIDDLE;
			
			content = _labelOff;
			
			_buttonBacking = new Box(_width, _height);
			_buttonBacking.style = _offStyle;
			backing = _buttonBacking;
			
			// Add mouse interaction listeners.
			addEventListener(MouseEvent.MOUSE_OVER, _mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, _mouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, _mouseDown);
			addEventListener(MouseEvent.MOUSE_UP, _mouseUp);
			
			_embedFonts = embed;
			
			_render();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get embedFonts():Boolean
		{
			return _embedFonts;
		}
		public function set embedFonts(value:Boolean):void
		{
			_embedFonts = value;
			_labelOff.embedFonts = _embedFonts;
			_labelOver.embedFonts = _embedFonts;
			_labelDown.embedFonts = _embedFonts;
		}
		
		public function get offStyle():BoxStyle
		{
			return _offStyle;
		}
		
		public function get overStyle():BoxStyle
		{
			return _overStyle;
		}
		
		public function get downStyle():BoxStyle
		{
			return _downStyle;
		}
		
		public function get offLabelFormat():TextFormat
		{
			return _offLabelFormat;
		}
		
		public function get overLabelFormat():TextFormat
		{
			return _overLabelFormat;
		}
		
		public function get downLabelFormat():TextFormat
		{
			return _downLabelFormat;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _mouseOver(e:MouseEvent):void
		{
			_buttonBacking.style = _overStyle;
			content = _labelOver;
		}
		private function _mouseOut(e:MouseEvent):void
		{
			_buttonBacking.style = _offStyle;
			content = _labelOff;
		}
		private function _mouseDown(e:MouseEvent):void
		{
			_buttonBacking.style = _downStyle;
			content = _labelDown;
		}
		private function _mouseUp(e:MouseEvent):void
		{
			_buttonBacking.style = _overStyle;
			content = _labelOver;
		}
	}
}
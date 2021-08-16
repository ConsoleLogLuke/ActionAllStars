package com.sdg.store.nav
{
	import com.sdg.display.AlignType;
	import com.sdg.display.ContainerGeneric;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	//public class StoreNavButton extends Container
	public class StoreNavButton extends ContainerGeneric
	{
		protected var _label:TextField;
		protected var _labelFormat:TextFormat;
		protected var _embedFonts:Boolean;
		protected var _background:ShopNavTab;
		//protected var _offStyle:BoxStyle;
		//protected var _overStyle:BoxStyle;
		//protected var _downStyle:BoxStyle;
		//protected var _buttonBacking:Box;
		
		public function StoreNavButton(label:String, width:Number=0, height:Number=0)
		{
			super(width, height, false);
			
			// Set initial values.
			_embedFonts = false;
			buttonMode = true;
			
			_label = new TextField();
			_label.defaultTextFormat = new TextFormat('Arial', 12, 0, true);
			_label.autoSize = TextFieldAutoSize.CENTER;
			_label.selectable = false;
			_label.mouseEnabled = false;
			_label.text = label;
			_label.border = false;
			_alignX = AlignType.MIDDLE;
			_alignY = AlignType.MIDDLE;
			content = _label;
			
			padding = 0;
			
			_background = new ShopNavTab();
			backing = _background;
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
	}
}
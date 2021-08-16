package com.sdg.pickem
{
	import com.sdg.display.AlignType;
	import com.sdg.display.Box;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.Container;
	import com.sdg.display.FillStyle;
	import com.sdg.display.Stack;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class InGamePickBox extends Container
	{
		private var _label:TextField;
		private var _pickImg:DisplayObject;
		private var _stack:Stack;
		private var _imgCtnr:Container;
		private var _lblCtnr:Container;
		private var _pickName:String;
		private var _imageFilters:Array;
		
		public function InGamePickBox(width:Number=0, height:Number=0)
		{
			super(width, height);
			
			_imageFilters = [new GlowFilter(0xffffff, 1, 2, 2, 10)];
			
			_stack = new Stack(AlignType.VERTICAL);
			_stack.equalizeSize = true;
			
			_imgCtnr = new Container();
			_imgCtnr.alignX = AlignType.MIDDLE;
			_imgCtnr.mouseEnabled = false;
			_stack.addContainer(_imgCtnr);
			
			_label = new TextField();
			_label.autoSize = TextFieldAutoSize.CENTER;
			_label.defaultTextFormat = new TextFormat('GillSans', 10, 0x1a2b5f, true);
			_label.embedFonts = true;
			_label.mouseEnabled = false;
			_label.text = '';
			
			_lblCtnr = new Container();
			_lblCtnr.alignX = AlignType.MIDDLE;
			_lblCtnr.content = _label;
			_lblCtnr.mouseEnabled = false;
			_stack.addContainer(_lblCtnr);
			
			// Create backing.
			var box:Box = new Box();
			box.style = new BoxStyle(new FillStyle(0x333333, 1), 0x969696, 1, 1, 6);
			backing = box;
			
			_paddingLeft = _paddingTop = _paddingRight = 2;
			
			content = _stack;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override protected function _render():void
		{
			super._render();
			
			_imgCtnr.width = _width - paddingLeft - paddingRight;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set image(value:DisplayObject):void
		{
			if (value == _pickImg) return;
			_pickImg = value;
			_pickImg.filters = _imageFilters;
			_imgCtnr.content = _pickImg;
			
			_render();
		}
		
		public function set pickName(value:String):void
		{
			if (value == _pickName) return;
			_pickName = value;
			_label.text = _pickName;
			
			_lblCtnr.content = _label
		}
		
		public function set imageFilters(value:Array):void
		{
			_imageFilters = value;
			_pickImg.filters = _imageFilters;
		}
		
	}
}
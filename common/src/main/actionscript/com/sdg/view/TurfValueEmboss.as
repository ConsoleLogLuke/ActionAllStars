package com.sdg.view
{
	import com.sdg.graphics.EmbossRect;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TurfValueEmboss extends FluidView
	{
		protected var _emboss:EmbossRect;
		protected var _isInit:Boolean;
		protected var _level:uint;
		protected var _turfIcon:Sprite;
		protected var _value:int;
		protected var _labelField:TextField;
		protected var _valueField:TextField;
		
		public function TurfValueEmboss(width:Number, height:Number, level:uint, value:int, autoInit:Boolean=true)
		{
			_isInit = false;
			_level = level;
			_value = value;
			
			_emboss = new EmbossRect(width, height, 0x555555);
			
			_turfIcon = new Sprite();
			
			_labelField = new TextField();
			_labelField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_labelField.embedFonts = true;
			_labelField.selectable = false;
			_labelField.autoSize = TextFieldAutoSize.LEFT;
			_labelField.text = 'Turf Value';
			
			_valueField = new TextField();
			_valueField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xecc101, true);
			_valueField.embedFonts = true;
			_valueField.selectable = false;
			_valueField.autoSize = TextFieldAutoSize.LEFT;
			_valueField.text = value.toString();
			
			super(width, height);
			
			addChild(_emboss);
			addChild(_turfIcon);
			addChild(_labelField);
			addChild(_valueField);
			
			if (autoInit == true) init();
		}
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			// Load logo.
			var turfUrl:String = AssetUtil.GetTurfIcon(_level);
			var turf:Sprite = new QuickLoader(turfUrl, render);
			_turfIcon.addChild(turf);
		}
		
		override protected function render():void
		{
			_emboss.width = width;
			_emboss.height = height;
			
			var w:Number = _width * 0.8;
			var h:Number = _height * 0.8;
			
			_valueField.x = 10;
			_valueField.y = _height - _valueField.height - 5;
			
			_labelField.x = _valueField.x;
			_labelField.y = _valueField.y - _labelField.height + 3;
			
			var iH:Number = _height - _labelField.y;
			
			var turfScale:Number = Math.min(w / _turfIcon.width, iH / _turfIcon.height);
			_turfIcon.width *= turfScale;
			_turfIcon.height *= turfScale;
			_turfIcon.x = _width / 2 - _turfIcon.width / 2;
			_turfIcon.y = _labelField.y - _turfIcon.height - 5;
		}
		
	}
}
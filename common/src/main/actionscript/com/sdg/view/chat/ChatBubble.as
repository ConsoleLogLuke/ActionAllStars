package com.sdg.view.chat
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class ChatBubble extends Sprite
	{
		protected var _text:String;
		
		private var _color1:uint;
		private var _color2:uint;
		private var _field:TextField;
		private var _bubble:Sprite;
		private var _fieldWidth:Number;
		private var _margin:Number;
		
		public function ChatBubble(text:String, color1:uint, color2:uint, maxWidth:Number = 160)
		{
			super();
			
			_text = text;
			_color1 = color1;
			_color2 = color2;
			_margin = 5;
			_fieldWidth = maxWidth - _margin * 2;
			
			_bubble = new Sprite();
			
			_field = new TextField();
			_field.defaultTextFormat = new TextFormat('EuroStyle', 14, _color1, null, null, null, null, null, TextFormatAlign.CENTER);
			_field.autoSize = TextFieldAutoSize.CENTER;
			_field.mouseEnabled = false;
			_field.selectable = false;
			_field.embedFonts = true;
			_field.multiline = true;
			_field.wordWrap = true;
			_field.text = _text;
			if (_field.width > _fieldWidth) _field.width = _fieldWidth;
			
			render();
			
			// Add displays.
			addChild(_bubble);
			addChild(_field);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Remove displays.
			removeChild(_bubble);
			removeChild(_field);
			
			// Remove references.
			_bubble = null;
			_field = null;
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function render():void
		{
			var margin:Number = 5;
			var corner:Number = 16;
			var point:Number = 10;
			var minW:Number = corner * 2 + point;
			var minH:Number = corner * 2;
			var bubbleW:Number = _field.width + margin * 2;
			bubbleW = Math.max(bubbleW, minW);
			var bubbleH:Number = _field.height + margin * 2;
			bubbleH = Math.max(bubbleH, minH);
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(bubbleW, bubbleH, Math.PI / 2);
			_bubble.graphics.clear();
			_bubble.graphics.lineStyle(2, _color1, 1, true);
			_bubble.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, _color2], [1, 1], [0, 255], gradMatrix);
			_bubble.graphics.moveTo(corner, 0);
			_bubble.graphics.lineTo(bubbleW - corner, 0);
			_bubble.graphics.curveTo(bubbleW, 0, bubbleW, corner);
			_bubble.graphics.lineTo(bubbleW, bubbleH - corner);
			_bubble.graphics.curveTo(bubbleW, bubbleH, bubbleW - corner, bubbleH);
			_bubble.graphics.lineTo(bubbleW / 2 + point / 2, bubbleH);
			_bubble.graphics.lineTo(bubbleW / 2, bubbleH + point);
			_bubble.graphics.lineTo(bubbleW / 2 - point / 2, bubbleH);
			_bubble.graphics.lineTo(corner, bubbleH);
			_bubble.graphics.curveTo(0, bubbleH, 0, bubbleH - corner);
			_bubble.graphics.lineTo(0, corner);
			_bubble.graphics.curveTo(0, 0, corner, 0);
			_bubble.graphics.endFill();
			
			_bubble.x = -bubbleW / 2;
			_bubble.y = -bubbleH - point;
			
			_field.x = _bubble.x + _bubble.width / 2 - _field.width / 2;
			_field.y = _bubble.y + margin;
		}
		
	}
}
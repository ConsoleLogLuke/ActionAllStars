package com.sdg.controls
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BasicTab extends Sprite
	{
		protected var _back:Sprite;
		protected var _field:TextField;
		protected var _margin:Number;
		protected var _color:uint;
		private var _tabHeight:Number;
		
		public function BasicTab(label:String, height:Number = 30, color:uint = 0x000000)
		{
			super();
			
			_margin = 10;
			_color = color;
			_tabHeight = height;
			
			_back = new Sprite();
			
			_field = new TextField();
			_field.defaultTextFormat = new TextFormat('Arial', 14, 0xffffff, true);
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.selectable = false;
			_field.mouseEnabled = false;
			_field.text = label;
			
			addChild(_back);
			addChild(_field);
			
			render();
		}
		
		protected function render():void
		{
			var w:Number = _field.width + _margin * 2;
			var h:Number = _tabHeight;
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(w + h, h, Math.PI / 2);
			
			_back.graphics.clear();
			_back.graphics.beginFill(_color);
			drawTab(_back.graphics, w, h);
			_back.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff], [0.4, 0], [1, 200], gradMatrix);
			_back.graphics.lineStyle(1, 0xffffff, 0.5);
			drawTab(_back.graphics, w, h);
			
			_field.x = _margin;
			_field.y = _tabHeight / 2 - _field.height / 2;
		}
		
		protected function drawTab(gfx:Graphics, labelWidth:Number, labelHeight:Number):void
		{
			var corner:Number = 5;
			
			gfx.moveTo(0, labelHeight);
			gfx.lineTo(0, corner);
			gfx.curveTo(0, 0, corner, 0);
			gfx.lineTo(labelWidth, 0);
			gfx.lineTo(labelWidth + labelHeight * 0.6, labelHeight);
		}
		
		public function get tabHeight():Number
		{
			return _tabHeight;
		}
		
	}
}
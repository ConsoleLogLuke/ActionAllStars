package com.sdg.gameMenus
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class RBIMenuButton extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _cornerRadius:Number;
		
		protected var _buttonText:TextField;
		
		protected var _color1:uint;
		protected var _color2:uint;
		protected var _textColor:uint;
		protected var _rollOverTextColor:uint;
		
		public function RBIMenuButton(buttonString:String, width:Number = 200, height:Number = 55, cornerRadius:Number = 10, fontSize:int = 28,
									color1:uint = 0xffffff, color2:int = 0xACB7BE,
									textColor:int = 0x597391, rollOverTextColor:uint = 0xA3B6C2)
		{
			super();
			_width = width;
			_height = height;
			_cornerRadius = cornerRadius;
			_color1 = color1;
			_color2 = color2;
			_textColor = textColor;
			_rollOverTextColor = rollOverTextColor;
			
			_buttonText = new TextField();
			_buttonText.defaultTextFormat = new TextFormat('EuroStyle', fontSize, textColor, true);
			_buttonText.embedFonts = true;
			_buttonText.autoSize = TextFieldAutoSize.LEFT;
			_buttonText.selectable = false;
			_buttonText.mouseEnabled = false;
			addChild(_buttonText);
			
			_buttonText.text = buttonString;
			
			_buttonText.x = _width/2 - _buttonText.width/2;
			_buttonText.y = _height/2 - _buttonText.height/2;						
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			buttonMode = true;
			
			setDefaultButtonStyle();
		}
		
		protected function onMouseOver(event:MouseEvent):void
		{
			setMouseOverButtonStyle();
		}
		
		protected function onMouseOut(event:MouseEvent):void
		{
			setDefaultButtonStyle();
		}
		
		public function destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		protected function setDefaultButtonStyle():void
		{
			graphics.clear();
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(_width, _height, Math.PI/2, 0, 0);
			
			graphics.lineStyle(2, _textColor);
			graphics.beginGradientFill(GradientType.LINEAR, [_color1, _color2], [1, 1], [1, 220], gradientBoxMatrix);
			graphics.drawRoundRect(0, 0, _width, _height, _cornerRadius, _cornerRadius);
			
			_buttonText.textColor = _textColor;
		}
		
		protected function setMouseOverButtonStyle():void
		{
			graphics.clear();
			
			graphics.beginFill(_color1);
			graphics.lineStyle(2, _rollOverTextColor);
			graphics.drawRoundRect(0, 0, _width, _height, _cornerRadius, _cornerRadius);
			
			_buttonText.textColor = _rollOverTextColor;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
	}
}
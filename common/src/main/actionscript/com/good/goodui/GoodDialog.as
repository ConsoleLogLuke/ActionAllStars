package com.good.goodui
{
	import flash.events.MouseEvent;
	
	public class GoodDialog extends GoodAlert
	{
		protected var _buttonHandler2:Function;
		protected var _button2:GoodButton;
		
		public function GoodDialog(width:Number, height:Number, message:String, buttonHandler1:Function = null, buttonHandler2:Function = null, buttonLabel1:String = 'OK', buttonLabel2:String = 'Cancel', buttonColor1:uint = 0x677192, buttonColor2:uint = 0x677192)
		{
			_button2 = new GoodButton(buttonLabel2, buttonColor2);
			
			super(width, height, message, buttonHandler1, buttonLabel1, buttonColor1);
			
			_buttonHandler2 = buttonHandler2;
			_button2.addEventListener(MouseEvent.CLICK, onButtonClick2);
			addChild(_button2);
		}
		
		override protected function render():void
		{
			super.render();
			
			var btnMargin:Number = 20;
			
			var buttonsW:Number = _button.width + _button2.width + btnMargin;
			
			_button.x = _width / 2 - buttonsW / 2;
			_button.y = _height - _button.height - _margin / 2;
			
			_button2.x = _button.x + _button.width + btnMargin;
			_button2.y = _button.y;
		}
		
		private function onButtonClick2(e:MouseEvent):void
		{
			if (_buttonHandler2 != null) _buttonHandler2();
		}
		
	}
}
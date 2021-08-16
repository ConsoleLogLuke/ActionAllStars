package com.good.goodui
{
	import flash.events.MouseEvent;
	
	public class GoodAlert extends GoodMessage
	{
		protected var _buttonHandler:Function;
		protected var _button:GoodButton;
		
		public function GoodAlert(width:Number, height:Number, message:String, buttonHandler:Function = null, buttonLabel:String = 'OK', buttonColor:uint = 0x677192)
		{
			_button = new GoodButton(buttonLabel, buttonColor);
			_button.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			super(width, height, message);
			
			_buttonHandler = buttonHandler;
			
			addChild(_button);
		}
		
		override protected function render():void
		{
			super.render();
			
			_button.x = _width / 2 - _button.width / 2;
			_button.y = _height - _button.height - _margin / 2;
		}
		
		private function onButtonClick(e:MouseEvent):void
		{
			if (_buttonHandler != null) _buttonHandler();
		}
		
	}
}
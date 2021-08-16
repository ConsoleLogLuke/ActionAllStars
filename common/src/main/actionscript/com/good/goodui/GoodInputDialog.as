package com.good.goodui
{
	public class GoodInputDialog extends GoodDialog
	{
		protected var _input:GoodInput;
		
		public function GoodInputDialog(width:Number, height:Number, message:String, input:GoodInput, buttonHandler1:Function=null, buttonHandler2:Function=null, buttonLabel1:String='OK', buttonLabel2:String='Cancel', buttonColor1:uint=0x677192, buttonColor2:uint=0x677192)
		{
			_input = input;
			
			super(width, height, message, buttonHandler1, buttonHandler2, buttonLabel1, buttonLabel2, buttonColor1, buttonColor2);
		
			addChild(_input);
		}
		
		override protected function render():void
		{
			super.render();
			
			// Re-position message.
			_messageField.y = _margin;
			
			// Position input.
			_input.width = _width - _margin * 2;
			_input.x = _width / 2 - _input.width / 2;
			_input.y = _messageField.y + _messageField.height + _margin / 2;
		}
		
	}
}
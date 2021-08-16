package com.good.goodui
{
	public class GoodDropDownDialog extends GoodDialog
	{
		protected var _dropDown:GoodDropDown;
		
		public function GoodDropDownDialog(width:Number, height:Number, message:String, dropDown:GoodDropDown, buttonHandler1:Function=null, buttonHandler2:Function=null, buttonLabel1:String='OK', buttonLabel2:String='Cancel', buttonColor1:uint=0x677192, buttonColor2:uint=0x677192)
		{
			_dropDown = dropDown;
			
			super(width, height, message, buttonHandler1, buttonHandler2, buttonLabel1, buttonLabel2, buttonColor1, buttonColor2);
			
			addChild(_dropDown);
		}
		
		override protected function render():void
		{
			super.render();
			
			// Re-position message.
			_messageField.y = _margin;
			
			// Position dropdown.
			_dropDown.width = _width - _margin * 2;
			_dropDown.x = _width / 2 - _dropDown.width / 2;
			_dropDown.y = _messageField.y + _messageField.height + _margin / 2;
		}
		
	}
}
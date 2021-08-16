package com.good.goodui
{
	import flash.events.MouseEvent;
	
	public class GoodButtonListDialog extends GoodMessage
	{
		protected var _buttons:Array;
		protected var _handlers:Array;
		
		public function GoodButtonListDialog(width:Number, height:Number, message:String, buttonLabels:Array, buttonHandlers:Array, buttonColors:Array = null)
		{
			_buttons = [];
			_handlers = buttonHandlers;
			
			super(width, height, message);
			
			// Create buttons.
			var i:uint = 0;
			var len:uint = buttonLabels.length;
			buttonColors = (buttonColors) ? buttonColors : [];
			for (i; i < len; i++)
			{
				var label:String = (buttonLabels[i]) ? buttonLabels[i] : 'Button ' + (i + 1);
				var color:uint = (buttonColors[i]) ? buttonColors[i] : 0x677192;
				var button:GoodButton = new GoodButton(label, color);
				button.addEventListener(MouseEvent.CLICK, onButtonClick);
				_buttons.push(button);
				addChild(button);
			}
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			// Re-position the message.
			_messageField.y = _margin;
			
			// Render buttons.
			var i:uint = 0;
			var len:uint = _buttons.length;
			var topButtonY:Number = _messageField.y + _messageField.height + _margin / 2;
			var buttonSpace:Number = 10;
			for (i; i < len; i++)
			{
				var button:GoodButton = _buttons[i] as GoodButton;
				button.width = _width - _margin * 2;
				button.x = _margin;
				button.y = topButtonY + i * (button.height + buttonSpace);
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onButtonClick(e:MouseEvent):void
		{
			// Determine index of clicked button.
			var index:int = _buttons.indexOf(e.currentTarget);
			if (index < 0) return;
			
			// Call the handler.
			var handler:Function = _handlers[index] as Function;
			if (handler != null) handler();
		}
		
	}
}
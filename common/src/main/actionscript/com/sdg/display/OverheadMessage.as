package com.sdg.display
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class OverheadMessage extends Sprite
	{
		private var textField:TextField;
		
		public function OverheadMessage(strokeColor:uint)
		{
			textField = new TextField();
			textField.filters = [new GlowFilter(strokeColor, 1, 6, 6, 10)];
			var format:TextFormat = new TextFormat();
			format.color = 0xffffff;
			//format.font = "Gillsans";
			format.font = "EuroStyle";
			//format.size formerly not set
			format.size = 8;
			format.bold = true;
			textField.defaultTextFormat = format;
			textField.embedFonts = true;
			textField.selectable = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
			addChild(textField);
			
			// hide message initially
			visible = false;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function showMessage(message:String):void
		{
			reset();
			textField.text = message;
			
			textField.x = - textField.width / 2;
			textField.y = - textField.height;
		}
		
		public function show():void
		{
			visible = true;
		}
		
		protected function reset():void
		{
			textField.text = "";
			show();
		}
    }
}
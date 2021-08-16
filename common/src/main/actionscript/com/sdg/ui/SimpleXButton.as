package com.sdg.ui
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class SimpleXButton extends InteractiveSoundMaker
	{
		protected var _x:TextField;
		protected var _circW:Number = 20;
		protected var _circH:Number = 20;
		protected var _cornerSize:Number;
		protected var _shape:String;
		
		public function SimpleXButton(shape:String,color:int = 0xffffff,circW:int = 20,circH:int = 20,cornerSize:int = 10)
		{
			super();
			
			this._shape = shape;
			this._circW = circW;
			this._circH = circH;
			this._cornerSize = cornerSize;
			
			_x = new TextField();
			_x.embedFonts = true;
			_x.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true);
			_x.text = 'X';
			_x.autoSize = TextFieldAutoSize.LEFT;
			_x.selectable = false;
			_x.mouseEnabled = false;
			addChild(_x);
			
			render();
		}
		
		protected function render():void
		{
			if (_shape == "Ellipse")
			{
				graphics.clear();
				graphics.beginFill(0x333333);
				graphics.lineStyle(2, 0xffffff);
				graphics.drawEllipse(0, 0, _circW, _circH);
				graphics.endFill();
				
				_x.x = _circW / 2 - _x.width / 2;
				_x.y = _circH / 2 - _x.height / 2;
			}
			else
			// "RoundRect"
			{
				graphics.clear();
				graphics.beginFill(0x333333);
				graphics.lineStyle(2, 0xffffff);
				graphics.drawRoundRect(0, 0, _circW, _circH, _cornerSize, _cornerSize);
				graphics.endFill();
				
				_x.x = _circW / 2 - _x.width / 2;
				_x.y = _circH / 2 - _x.height / 2;
			}
		}
	}
}
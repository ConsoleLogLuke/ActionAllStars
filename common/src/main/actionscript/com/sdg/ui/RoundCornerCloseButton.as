package com.sdg.ui
{
	import flash.geom.Rectangle;
	
	public class RoundCornerCloseButton extends GoodCloseButton
	{
		protected var _cornerSize:Number;
		
		public function RoundCornerCloseButton(label:String='Close')
		{
			// Defaults.
			_cornerSize = 10;
			
			super(label);
		}
		
		override protected function render():void
		{
			graphics.clear();
			graphics.beginFill(0x333333);
			graphics.lineStyle(2, 0xffffff);
			graphics.drawRoundRect(0, 0, _circW, _circH, _cornerSize, _cornerSize);
			graphics.endFill();
			
			_x.x = _circW / 2 - _x.width / 2;
			_x.y = _circH / 2 - _x.height / 2;
			
			if (_showLabel == true)
			{
				_labelField.x = -_labelField.width - 5;
				_labelField.y = _circH / 2 - _labelField.height / 2;
				var labelBounds:Rectangle = _labelField.getBounds(this);
				
				graphics.beginFill(0x333333);
				graphics.lineStyle(2, 0xffffff);
				graphics.drawRoundRect(labelBounds.x - 5, 0, _circW + labelBounds.width + 10, _circH, _cornerSize, _cornerSize);
				
				_labelField.visible = true;
			}
			else
			{
				_labelField.visible = false;
			}
		}
		
	}
}
package com.sdg.store.nav
{
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.controls.BasicButton;
	import com.sdg.display.AlignType;
	
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;

	public class StoreNavButtonTop extends BasicButton
	{
		protected var _buttonMask:Sprite;
		
		public function StoreNavButtonTop(label:String, width:Number=0, height:Number=0, style:IButtonStyle=null)
		{
			_buttonMask = new Sprite();
			
			super(label, width, height, style);
			
			_addChild(_buttonMask);
			_buttonBacking.mask = _buttonMask;
			
			_alignX = AlignType.LEFT;
			_label.autoSize = TextFieldAutoSize.LEFT;
			_paddingLeft = 10;
			
			_render();
		}
		
		override protected function _render():void
		{
			super._render();
			
			var size:Number = 12;
			var bevel:Number = 1.4;
			
			// Draw button mask.
			_buttonMask.graphics.clear();
			_buttonMask.graphics.beginFill(0x00ff00);
			_buttonMask.graphics.moveTo(size * bevel, 0);
			_buttonMask.graphics.lineTo(_width - size, 0);
			_buttonMask.graphics.curveTo(_width, 0, _width, size);
			_buttonMask.graphics.lineTo(_width, _height);
			_buttonMask.graphics.lineTo(0, _height);
			_buttonMask.graphics.lineTo(0, size);
		}
		
	}
}
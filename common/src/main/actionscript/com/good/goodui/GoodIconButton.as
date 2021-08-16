package com.good.goodui
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class GoodIconButton extends GoodButton
	{
		protected var _icon:DisplayObject;
		protected var _useLabel:Boolean;
		
		public function GoodIconButton(label:String, icon:DisplayObject, color:uint=0x677192)
		{
			_icon = icon;
			_useLabel = true;
			
			super(label, color);
			
			_icon.filters = [_shadow];
			addChild(_icon);
		}
		
		override protected function render():void
		{
			// Scale the icon.
			var maxH:Number = _field.height - _margin * 2;
			var scale:Number = Math.min(maxH / _icon.height, maxH / _icon.width);
			_icon.width *= scale;
			_icon.height *= scale;
			
			_width = (_useLabel) ? _field.width + _icon.width * 2 + 20 + _height : _height;
			
			super.render();
			
			// Position the icon.
			var iconBounds:Rectangle = _icon.getBounds(this);
			var offX:Number = ((_useLabel) ? (_height / 2) : (_height / 2 - iconBounds.width / 2)) - iconBounds.x;
			var offY:Number = (_height / 2 - iconBounds.height / 2) - iconBounds.y;
			_icon.x += offX;
			_icon.y += offY;
			
			// Re-position the label field.
			_field.x += (iconBounds.width) / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get useLabel():Boolean
		{
			return _useLabel;
		}
		public function set useLabel(value:Boolean):void
		{
			if (value == _useLabel) return;
			_useLabel = value;
			_field.visible = _useLabel;
			render();
		}
		
	}
}
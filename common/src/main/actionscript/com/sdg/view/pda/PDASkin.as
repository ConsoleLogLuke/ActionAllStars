package com.sdg.view.pda
{
	import com.sdg.graphics.customShapes.interfaces.ICustomShape;
	
	import mx.core.UIComponent;
	
	public class PDASkin extends UIComponent
	{
		private var _shape:ICustomShape;
		private var _color:uint;
		
		public function PDASkin(color:uint = 0x000000, shape:ICustomShape = null)
		{
			super();
			_color = color;
			_shape = shape;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			if (_shape)
			{
				_shape.width = this.width;
				_shape.height = this.height;
			}
			draw();
		}
		
		private function draw():void
		{
			graphics.clear();
			graphics.beginFill(_color);
			
			if (_shape) _shape.draw(graphics);
			
			graphics.endFill();
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			if (value == _color) return;
			
			_color = value;
			this.invalidateDisplayList();
		}
		
		public function get shape():ICustomShape
		{
			return _shape;
		}
		
		public function set shape(value:ICustomShape):void
		{
			_shape = value;
			if (_shape)
			{
				this.width = _shape.width;
				this.height = _shape.height;
			}
			this.invalidateDisplayList();
		}
	}
}

package com.sdg.view.pda
{
	import com.sdg.graphics.customShapes.interfaces.ICustomShape;
	
	import mx.containers.Canvas;
	
	public class SkinableContainer extends Canvas
	{
		private var _skin:PDASkin;
		
		public function SkinableContainer()
		{
			super();
			_skin = this.addChild(new PDASkin()) as PDASkin;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			_skin.alpha = this.getStyle("backgroundAlpha");
		}
		
		public function get skin():PDASkin
		{
			return _skin;
		}
		
		public function set skinColor(value:uint):void
		{
			_skin.color = value;
		}
		
		public function set skinShape(value:ICustomShape):void
		{
			_skin.shape = value;
		}
	}
}
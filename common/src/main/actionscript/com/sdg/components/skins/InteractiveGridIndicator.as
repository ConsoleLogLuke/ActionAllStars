package com.sdg.components.skins
{
	import flash.display.Graphics;
	
	import mx.skins.ProgrammaticSkin;

	public class InteractiveGridIndicator extends ProgrammaticSkin
	{
		public function InteractiveGridIndicator()
		{
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{	
			super.updateDisplayList(w, h);
			
			var color:uint = getStyle("rollOverColor");
			
			var g:Graphics = graphics;
			
			g.clear();
			g.lineStyle(1, color, .65, false, "none");
	        g.beginFill(color, .35);
	        g.drawRect(0, 0, w, h);
	        g.endFill();
		}
	}
}
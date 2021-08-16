package com.sdg.skate
{
	import com.sdg.view.GamePlaceView;
	
	import flash.display.DisplayObject;

	public class SkateGamePlaceView extends GamePlaceView
	{
		public function SkateGamePlaceView(iconSize:Number=20, spacing:Number=10)
		{
			super(iconSize, spacing);
		}
		
		override protected function createIcon(color:uint):DisplayObject
		{
			var i:SkatePlaceIcon = new SkatePlaceIcon();
			i.color = color;
			// Scale icon.
			var scale:Number = Math.min(_iconSize / i.width, _iconSize / i.height);
			i.width *= scale;
			i.height *= scale;
			
			return DisplayObject(i);
		}
		
	}
}
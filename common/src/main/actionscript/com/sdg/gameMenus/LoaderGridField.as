package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	
	public class LoaderGridField extends GridField
	{
		public function LoaderGridField(width:Number, height:Number, url:String, centerAligned:Boolean=true, leftMargin:int=0)
		{
			var display:DisplayObject = new QuickLoader(url, onComplete);
			super(width, height, display, centerAligned, leftMargin);
			
			function onComplete():void
			{
				var scale:Number = Math.min(width/display.width, height/display.height);
				display.scaleX = display.scaleY = scale;
				render();
			}
		}
	}
}
package com.sdg.gameMenus
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class RBIStandardMenu extends GradientGameBody
	{
		protected var _finishedButton:RBIMenuButton;
		
		public function RBIStandardMenu(menuName:String, width:Number=925, height:Number=515)
		{
			super(menuName, width, height);
			
			var footer:ButtonFooter = new ButtonFooter(width);
			footer.x = _width/2 - footer.width/2;
			footer.y = _height - footer.height;
			
			_finishedButton = new RBIMenuButton("FINISHED");
			footer.button = _finishedButton;
			_finishedButton.addEventListener(MouseEvent.CLICK, onClick);
			addChild(footer);
		}
		
		protected function onClick(event:MouseEvent):void
		{
			dispatchEvent(new Event("returnToMenu"));
		}
		
		public function destroy():void
		{
			_finishedButton.removeEventListener(MouseEvent.CLICK, onClick);
			_finishedButton.destroy();
		}
	}
}
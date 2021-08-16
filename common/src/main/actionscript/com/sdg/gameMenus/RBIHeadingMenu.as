package com.sdg.gameMenus
{
	import flash.display.DisplayObject;
	
	public class RBIHeadingMenu extends HeadingMenu
	{
		public function RBIHeadingMenu(width:Number, height:Number)
		{
			super(width, height);
			
			var rbiHeader:GameHeader = new GameHeader();
			rbiHeader.backgroundUrl = "assets/swfs/rbi/menuHeader.swf";
			rbiHeader.gameLogoUrl = "assets/swfs/rbi/rbiLogo.swf";
			rbiHeader.leagueLogoUrl = "assets/swfs/rbi/mlbLogo.swf";
			header = rbiHeader;
		}
		
		override public function set body(value:GameBody):void
		{
			super.body = value;
			_header.titleString = value.menuName;
		}
	}
}
package com.sdg.gameMenus
{
	import com.sdg.model.Avatar;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RBIStatsBody extends RBIStandardMenu
	{
		protected var _statsList:MyStatsListWindow;
		
		public function RBIStatsBody(avatar:Avatar, width:Number = 925, height:Number = 515)
		{
			super("MY STATS", width, height);
			
			_statsList = new MyStatsListWindow();
			_statsList.x = _width/2 - _statsList.width/2;
			_statsList.y = 85;
			
			addChild(_statsList);
			
			var nameText:TextField = new TextField();
			nameText.defaultTextFormat = new TextFormat('EuroStyle', 27, 0xffffff, true);
			nameText.embedFonts = true;
			nameText.autoSize = TextFieldAutoSize.LEFT;
			nameText.selectable = false;
			nameText.mouseEnabled = false;
			nameText.text = avatar.name;
			nameText.x = _statsList.x + 10;
			nameText.y = _gradientBox.y + 5;
			addChild(nameText);
			
			var descriptionText:TextField = new TextField();
			descriptionText.defaultTextFormat = new TextFormat('EuroStyle', 13, 0x848A8C, true);
			descriptionText.embedFonts = true;
			descriptionText.autoSize = TextFieldAutoSize.LEFT;
			descriptionText.selectable = false;
			descriptionText.mouseEnabled = false;
			descriptionText.text = "Current Statistics for " + avatar.name;
			descriptionText.x = _statsList.x + 10;
			descriptionText.y = nameText.y + nameText.height - 5;
			addChild(descriptionText);
		}
		
		public function set stats(value:Array):void
		{
			_statsList.stats = value;
		}
	}
}
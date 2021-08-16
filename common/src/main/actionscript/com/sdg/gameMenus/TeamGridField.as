package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TeamGridField extends GridField
	{
		public function TeamGridField(width:Number, height:Number, teamId:int, teamName:String, fontSize:int = 16, centerAligned:Boolean = true, leftMargin:int = 0)
		{
			var display:Sprite = new Sprite();
			var logo:DisplayObject = new QuickLoader(AssetUtil.GetTeamLogoUrl(teamId), onComplete);
			
			var nameField:TextField = new TextField();
			nameField.defaultTextFormat = new TextFormat('EuroStyle', fontSize, 0x335580, true);
			nameField.embedFonts = true;
			nameField.autoSize = TextFieldAutoSize.LEFT;
			nameField.selectable = false;
			nameField.mouseEnabled = false;
			nameField.text = teamName;
			
			display.addChild(logo);
			display.addChild(nameField);
			
			super(width, height, display, centerAligned, leftMargin);
			
			function onComplete():void
			{
				var scale:Number = Math.min(width/display.width, height/display.height);
				logo.scaleX = logo.scaleY = scale;
				logo.y = display.height/2 - logo.height/2;
				nameField.x = logo.x + logo.width + 3;
				nameField.y = display.height/2 - nameField.height/2;
				render();
			}
		}
	}
}
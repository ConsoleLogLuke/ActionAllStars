package com.sdg.components.controls
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.net.QuickLoader;

	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class ModeratorAlertChrome extends SdgAlertChrome
	{
		public function ModeratorAlertChrome(message:String, title:String, width:int, height:int)
		{
			super(message, title, false, width, height, null, "swfs/alert/popup_siren.swf");

			_titleTF.textColor = 0xfd0000;

			addButton("CLOSE", 1);
			setFocus();
		}

		public static function show(message:String, title:String, closeHandler:Function = null, parent:Sprite = null,
									modal:Boolean = true, width:int = 430, height:int = 200):ModeratorAlertChrome
		{
			var alert:ModeratorAlertChrome = new ModeratorAlertChrome(message, title, width, height);

			alert.show(closeHandler, parent, modal);
			return alert;
		}

	}
}

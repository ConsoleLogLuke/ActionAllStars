package com.sdg.gameMenus
{
	import com.sdg.events.AvatarUpdateEvent;
	import com.sdg.model.Avatar;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RBIStoreBody extends RBIStandardMenu
	{
		protected var _storeList:RBIStoreListWindow;
		protected var _avatar:Avatar;
		protected var _tokenDisplay:MyTokensDisplay;
		
		public function RBIStoreBody(avatar:Avatar, width:Number = 925, height:Number = 515)
		{
			super("BUY TEAMS", width, height);
			
			_avatar = avatar;
			
			_storeList = new RBIStoreListWindow();
			_storeList.x = _width/2 - _storeList.width/2;
			_storeList.y = 85;
			
			addChild(_storeList);
			
			var nameText:TextField = new TextField();
			nameText.defaultTextFormat = new TextFormat('EuroStyle', 27, 0xffffff, true);
			nameText.embedFonts = true;
			nameText.autoSize = TextFieldAutoSize.LEFT;
			nameText.selectable = false;
			nameText.mouseEnabled = false;
			nameText.text = avatar.name;
			nameText.x = _storeList.x + 10;
			nameText.y = _gradientBox.y + 5;
			addChild(nameText);
			
			var descriptionText:TextField = new TextField();
			descriptionText.defaultTextFormat = new TextFormat('EuroStyle', 13, 0x848A8C, true);
			descriptionText.embedFonts = true;
			descriptionText.autoSize = TextFieldAutoSize.LEFT;
			descriptionText.selectable = false;
			descriptionText.mouseEnabled = false;
			descriptionText.text = "Play as your favorite team";
			descriptionText.x = _storeList.x + 10;
			descriptionText.y = nameText.y + nameText.height - 5;
			addChild(descriptionText);
			
			_tokenDisplay = new MyTokensDisplay(avatar.currency);
			_avatar.addEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onTokensUpdate);
			_tokenDisplay.x = _storeList.x + 200;
			_tokenDisplay.y = _gradientBox.y + 8;
			addChild(_tokenDisplay);
		}
		
		protected function onTokensUpdate(event:AvatarUpdateEvent):void
		{
			_tokenDisplay.tokens = _avatar.currency;
		}
		
		override public function destroy():void
		{
			super.destroy();
			_avatar.removeEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onTokensUpdate);
			_storeList.destroy();
		}
		
		public function set storeItems(value:Array):void
		{
			_storeList.storeItems = value;
		}
	}
}
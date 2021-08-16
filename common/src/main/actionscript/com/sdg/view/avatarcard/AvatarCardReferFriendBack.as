package com.sdg.view.avatarcard
{
	import com.good.goodui.FluidView;
	import com.sdg.model.Avatar;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.BitmapUtil;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class AvatarCardReferFriendBack extends FluidView
	{
		protected var _avatar:Avatar;
		protected var _background:Sprite;
		protected var _oval:Sprite;
		// Action Allstars Title
		protected var _aasTitle:TextField;
		// 1st paragraph
		protected var _instructions:TextField;
		// 1st paragraph line 1
		protected var _instructionsLine1:TextField;
		// 1st paragraph line 2
		protected var _instructionsLine2:TextField;
		// 1st paragraph line 3
		protected var _instructionsLine3:TextField;
		// Athlete Name Prompt
		protected var _avatarNamePrompt:TextField;
		// Athlete Name
		protected var _avatarName:TextField;
		// how to get reward line 1
		protected var _rewardInfo:TextField;
		// how to get reward line 2
		protected var _rewardInfoLine2:TextField;
		// Item Name
		protected var _itemName:TextField;
		
		
		public function AvatarCardReferFriendBack(avatar:Avatar, width:Number, height:Number)
		{
			_avatar = avatar;
			
			_instructions = new TextField();
			_instructions.defaultTextFormat = new TextFormat('EuroStyle', 18, 0x000000, true,null,null,null,null,"center");
			_instructions.embedFonts = true;
			_instructions.selectable = false;
			_instructions.autoSize = TextFieldAutoSize.LEFT;
			_instructions.text = "Create your own Athlete\nand enter my name\nin the referral section";
			_instructions.cacheAsBitmap = true;
			
			_avatarNamePrompt = new TextField();
			_avatarNamePrompt.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			_avatarNamePrompt.embedFonts = true;
			_avatarNamePrompt.selectable = false;
			_avatarNamePrompt.autoSize = TextFieldAutoSize.LEFT;
			_avatarNamePrompt.text = "Enter this Athlete name:";
			_avatarNamePrompt.cacheAsBitmap = true;
			
			_avatarName = new TextField();
			_avatarName.defaultTextFormat = new TextFormat('EuroStyle', 23, 0xffffff, true, null,null,null,null,"center");
			_avatarName.embedFonts = true;
			_avatarName.selectable = false;
			_avatarName.autoSize = TextFieldAutoSize.LEFT;
			_avatarName.text = _avatar.name;
			_avatarName.cacheAsBitmap = true;
			
			_rewardInfo = new TextField();
			_rewardInfo.defaultTextFormat = new TextFormat('EuroStyle', 18, 0x000000, true,null,null,null,null,"center");
			_rewardInfo.embedFonts = true;
			_rewardInfo.selectable = false;
			_rewardInfo.autoSize = TextFieldAutoSize.LEFT;
			_rewardInfo.text = "Register for FREE to earn a:\nSkull Crazy Snowboard Suit";
			_rewardInfo.cacheAsBitmap = true;
			
			_background = new Sprite();
			_background.cacheAsBitmap = true;
			
			_oval = new Sprite();
			_oval.cacheAsBitmap = true;
			
			super(width, height);
		}
		
		public function init():void
		{
			addChild(_background);
			addChild(_oval);
			
			addChild(_instructions);
			addChild(_avatarNamePrompt);
			addChild(_avatarName);
			addChild(_rewardInfo);


			// Load Background
			var url:String = AssetUtil.GetGameAssetUrl(99, 'referFriendBack.swf');
			var cardBack:Sprite = new QuickLoader(url, render, null, 2);
			_background.addChild(cardBack);
		}
		
		override protected function render():void
		{
			_background.width = _width;
			_background.height = _height;
			
			// Scale Text Fields
			var scale:Number = 0;
			if ((_width > 320)||(_width < 320))
			{
				scale = _width/320;
			}
			else
			{
				scale = 1;
			}
			
			// Draw Oval to proper scale
			var gradientBoxMatrix:Matrix = new Matrix();
			var ovalWidth:uint = _width*(285/320);
			var ovalHeight:uint = _height*(56/450);
			gradientBoxMatrix.createGradientBox(ovalWidth, ovalHeight, Math.PI/2);
			_oval.graphics.beginGradientFill(GradientType.LINEAR,[0x0057ae,0x003468],[1,1],[1,255],gradientBoxMatrix);
			_oval.graphics.drawRoundRect(0,0,ovalWidth,ovalHeight,15,15);
			
			_oval.x = _width*(17/320);
			_oval.y = _height*(141/450);

			_instructions.scaleX *= scale;
			_instructions.scaleY *= scale;
			_avatarNamePrompt.scaleX *= scale;
			_avatarNamePrompt.scaleY *= scale;
			_avatarName.scaleX *= scale;
			_avatarName.scaleY *= scale;
			_rewardInfo.scaleX *= scale;
			_rewardInfo.scaleY *= scale;
			
			// position all textfields
			_instructions.y = _height*(65/450);
			_instructions.x = _width / 2 - _instructions.width / 2;
			
			_avatarNamePrompt.y = _height*(140/450);
			_avatarNamePrompt.x = _width / 2 - _avatarNamePrompt.width / 2;
			
			_avatarName.y = _height*(165/450);
			_avatarName.x = _width / 2 - _avatarName.width / 2;
			
			_rewardInfo.y = _height*(200/450);
			_rewardInfo.x = _width / 2 - _rewardInfo.width / 2;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function getScaledBitmap(scale:Number,smooth:Boolean=false):Bitmap
		{	
			var cardMap:Bitmap = BitmapUtil.spriteToBitmap(this,smooth);
			cardMap.scaleX *= scale;
			cardMap.scaleY *= scale;
			
			return cardMap;
		}
		
	}
}
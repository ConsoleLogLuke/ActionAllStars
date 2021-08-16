package com.sdg.components.dialog
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.control.AASModuleLoader;
	import com.sdg.display.LineStyle;
	import com.sdg.events.ChallengesEvent;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.store.StoreConstants;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	public class ChallengeResultDialog extends Canvas implements ISdgDialog
	{
		
		// INTERNAL CONSTANTS
		private var WIDTH:uint = 828;
		private var HEIGHT:uint = 532;
		private var FRAMING_WIDTH:uint = 668;
		private var FRAMING_HEIGHT:uint = 414;
		private var FRAMING_X:uint = 80;
		private var FRAMING_Y:uint = 40;
		private var CHALLENGE_TEXT_INDENT:uint = 310;
		private var CHALLENGE_TEXT_Y_INDENT:uint = 165;
		
		// INPUTS = Defaults
		protected var _gameId:String = "11";
		protected var _success:Boolean = false;
		protected var _challengeText:String = "Unavailable";
		protected var _tokenReward:String = "0";
		protected var _xpReward:String = "0";
		protected var _challengeIconUrl:String = "";
		protected var _avatarId:String = "-1";
		protected var _challengeRank:String = "10";
		protected var _gameLogoUrl:String = "/test/static/gameImage?gameId=11";
		
		// COMPONENTS
		protected var _border:Sprite;
		protected var _background:Sprite;
		protected var _framing:Sprite;
		protected var _title:TextField;
		protected var _subTitle:TextField;
		protected var _challengeHeader:TextField;
		protected var _challengeField:TextField;
		protected var _awardText:TextField;
		protected var _tokenText:TextField;
		protected var _xpText:TextField;
		protected var _storeMessage:TextField;
		protected var _playButton:StoreNavBar;
		protected var _worldButton:StoreNavBar;
		protected var _challengeIcon:DisplayObject;
		protected var _goldTokensIcon:DisplayObject;
		protected var _xpIcon:DisplayObject;
		protected var _storeIcon:DisplayObject;
		
		protected var _debug:Boolean;
		
		protected var _linkToStoreId:uint = 2209; // default to AAS
		
		protected var _achievementData:XML;
		protected var _testString:String = "TESTETEST\n";
		
		public function ChallengeResultDialog()
		{
			super();

			this.width = WIDTH;
			this.height = HEIGHT;
		}
		
		public function init(params:Object):void
		{
			if (params)
			{
				var achievementData:XML = params.xml as XML;

				_gameId = String(achievementData.gameId);
				_gameLogoUrl = String(achievementData.gameLogo);
				_challengeIconUrl = String(achievementData.playerImage);
				_tokenReward = String(achievementData.tokensEarned);
				_xpReward = String(achievementData.experienceEarned);
				_challengeText = String(achievementData.challengeDescription);
				_challengeRank = String(achievementData.achievementRequirementValue);
				
				var intGameId:int = 0;
				try {intGameId = parseInt(_gameId);}
				catch (e:Error) {return;}
				_linkToStoreId = StoreConstants.getStoreFromGameId(intGameId);
				
				if (achievementData.challengeStatus == 1)
				{
					_success = true;
				}
				else
				{
					_success = false;
				}
			}
			
			showDialog();
		}
		
		public function showDialog():void
		{
			// Set Border
			_border = new Sprite();
			this.rawChildren.addChild(_border);
			
			var gradientBoxMatrix:Matrix = new Matrix();

			gradientBoxMatrix.createGradientBox(WIDTH, HEIGHT, Math.PI/2);
			_border.graphics.beginGradientFill(GradientType.LINEAR, [0x666666, 0xffffff, 0x666666], [1, 1, 1], [0, 128, 255], gradientBoxMatrix);
			_border.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			_border.graphics.endFill();
			
			// Set Background
			_background = new Sprite();
			this.rawChildren.addChild(_background);
			
			gradientBoxMatrix.createGradientBox(width-16, height-16, Math.PI/2);
			_background.graphics.beginGradientFill(GradientType.LINEAR, [0x063040, 0x0e526c], [1, 1], [0, 255], gradientBoxMatrix);
			
			_background.graphics.drawRect(0, 0, width-16, height-16);
			_background.graphics.endFill();
			_background.x = _border.width/2 - _background.width/2;
			_background.y = _border.height/2 - _background.height/2;
			_background.filters = [new GlowFilter(0x222222, 1, 11, 11, 2, 1, true)];
			
			// Set Background
			_framing = new Sprite();
			this.rawChildren.addChild(_framing);
			
			_framing.x = 0;
			_framing.y = 0;
			_framing.graphics.beginFill(0x000000,.4);
			_framing.graphics.drawRect(FRAMING_X,FRAMING_Y,FRAMING_WIDTH,FRAMING_HEIGHT)
			_framing.graphics.endFill();
			
			// Place Buttons
			buildButton(190,465,170,"PLAY AGAIN","PLAY AGAIN","onPlayAgainClick");
			buildButton(390,465,210,"BACK TO WORLD","BACK TO WORLD","onWorldClick");
			
			_challengeIcon = new QuickLoader(Environment.getAssetUrl()+_challengeIconUrl, onChallengeIconLoadComplete,null,3);
			
			_title = new TextField();
			this.rawChildren.addChild(_title);
			_title.embedFonts = true;
			if (_success)
			{
				_title.defaultTextFormat = new TextFormat('EuroStyle', 40, 0xffffff, true);
				_title.x = 190;
				_title.text = "CONGRATULATIONS!";
			}
			else
			{
				_title.defaultTextFormat = new TextFormat('EuroStyle', 35, 0xffffff, true);
				//_title.x = 270;
				//_title.text = "TRY AGAIN!";
				_title.x = 205
				_title.text = "Sorry, Challenge Lost";
			}
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.selectable = false;
			_title.y = 60;
			_title.filters = [new GlowFilter(0x3cc6db, .6, 6, 6, 4)];
		
			_subTitle = new TextField();
			this.rawChildren.addChild(_subTitle);
			_subTitle.embedFonts = true;
			_subTitle.defaultTextFormat = new TextFormat('EuroStyle', 40, 0xffffff, true);
			_subTitle.autoSize = TextFieldAutoSize.LEFT;
			_subTitle.selectable = false;
			if (_success)
			{
				_subTitle.x = 220;
				_subTitle.text = "Challenge Passed!";
			}
			else
			{
				//_subTitle.x = 170;
				//_subTitle.text = "Challenge Failed!";
				//_subTitle.text = "Sorry, Challenge Lost";
				_subTitle.x = 275;
				_subTitle.text = "TRY AGAIN!";
			}
			_subTitle.y = 108;
			_subTitle.filters = [new GlowFilter(0x3cc6db, .6, 6, 6, 4)];
			
			_challengeHeader = new TextField();
			this.rawChildren.addChild(_challengeHeader);
			_challengeHeader.embedFonts = true;
			_challengeHeader.defaultTextFormat = new TextFormat('EuroStyle', 25, 0xffffff, true);
			_challengeHeader.autoSize = TextFieldAutoSize.LEFT;
			_challengeHeader.selectable = false;
			_challengeHeader.text = "CHALLENGE: "+intToRank(_challengeRank);
			_challengeHeader.x = CHALLENGE_TEXT_INDENT;
			_challengeHeader.y = CHALLENGE_TEXT_Y_INDENT;
			
			_challengeField = new TextField();
			this.rawChildren.addChild(_challengeField);
			_challengeField.embedFonts = true;
			_challengeField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, false);
			//_challengeField.defaultTextFormat = new TextFormat('GillSands', 18, 0xffffff, true);
			_challengeField.selectable = false;
			_challengeField.multiline = true;
			_challengeField.wordWrap = true;
			_challengeField.htmlText = _challengeText;
			_challengeField.x = CHALLENGE_TEXT_INDENT;
			_challengeField.y = 195;
			_challengeField.width = 400;
			
			_awardText = new TextField();
			this.rawChildren.addChild(_awardText);
			_awardText.embedFonts = true;
			_awardText.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			_awardText.autoSize = TextFieldAutoSize.LEFT;
			_awardText.selectable = false;
			_awardText.text = "You've Been Awarded:";
			_awardText.x = CHALLENGE_TEXT_INDENT;
			_awardText.y = 250;
			
			//_goldTokensIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/icon_3Tokens_payout.swf', onTokensIconLoadComplete,null,3);
			
			_tokenText = new TextField();
			this.rawChildren.addChild(_tokenText);
			_tokenText.embedFonts = true;
			_tokenText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			_tokenText.autoSize = TextFieldAutoSize.LEFT;
			_tokenText.selectable = false;
			_tokenText.text = "+ "+_tokenReward+" TOKENS";
			_tokenText.x = CHALLENGE_TEXT_INDENT;
			_tokenText.y = 285;
			_tokenText.filters = [new GlowFilter(0xffcc33, 1, 6, 6, 1)];
			
			//_xpIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/icon_XP_payout.swf', onXPIconLoadComplete,null,3);

			_xpText = new TextField();
			this.rawChildren.addChild(_xpText);
			_xpText.embedFonts = true;
			_xpText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			_xpText.autoSize = TextFieldAutoSize.LEFT;
			_xpText.selectable = false;
			_xpText.text = "+ "+_xpReward+" POINTS";
			_xpText.x = CHALLENGE_TEXT_INDENT;
			_xpText.y = 333;
			_xpText.filters = [new GlowFilter(0x0066cc, 1, 6, 6, 2)];
			
			if (_linkToStoreId == 2061)
			{
				_storeIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/ShopBtn_Anim_Ylw_NBA.swf', onStoreIconLoadComplete,null,3);
			}
			else if (_linkToStoreId == 2095)
			{
				_storeIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/ShopBtn_Anim_Ylw_MLB.swf', onStoreIconLoadComplete,null,3);
			}
			else
			{
				_storeIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/ShopBtn_Anim_Ylw_AAS.swf', onStoreIconLoadComplete,null,3);
			}
			
			_storeMessage = new TextField();
			this.rawChildren.addChild(_storeMessage);
			_storeMessage.embedFonts = true;
			_storeMessage.defaultTextFormat = new TextFormat('EuroStyle', 13, 0xffffff, true);
			_storeMessage.selectable = false;
			_storeMessage.multiline = true;
			_storeMessage.wordWrap = true;
			_storeMessage.text = "Visit one of the official shops to collect the latest gear.";
			_storeMessage.x = CHALLENGE_TEXT_INDENT+172;
			_storeMessage.y = 393;
			_storeMessage.width = 201;
			_storeMessage.height = 60;
			
		}
		
		private function onChallengeIconLoadComplete():void
		{
			this.rawChildren.addChild(_challengeIcon);
			_challengeIcon.x = 155;
			_challengeIcon.y = CHALLENGE_TEXT_Y_INDENT-3;
		}
		
		private function onTokensIconLoadComplete():void
		{
			this.rawChildren.addChild(_goldTokensIcon);
			_goldTokensIcon.x = CHALLENGE_TEXT_INDENT+3;
			_goldTokensIcon.y = 285;
		}
		
		private function onXPIconLoadComplete():void
		{
			this.rawChildren.addChild(_xpIcon);
			_xpIcon.x = CHALLENGE_TEXT_INDENT+3;
			_xpIcon.y = 350;
		}
		
		private function onStoreIconLoadComplete():void
		{
			this.rawChildren.addChild(_storeIcon);
			_storeIcon.x = CHALLENGE_TEXT_INDENT;
			_storeIcon.y = 387;
			_storeIcon.scaleX = 1;
			_storeIcon.scaleY = 1;
			_storeIcon.addEventListener(MouseEvent.CLICK,onStoreClick);
		}
		
		private function onStoreClick(e:MouseEvent):void
		{
			var params:Object = new Object();
			
			var intGameId:int;
			try {intGameId = parseInt(_gameId);}
			catch (e:Error) {return;}
			
			params.storeId = _linkToStoreId;
			AASModuleLoader.openStoreModule(params);
			this.close();
		}
		
		/////////////////////////////////////
		// BUTTON FUNCTIONS
		/////////////////////////////////////
		private function buildButton(x:int,y:int,width:uint,initialText:String,onClickText:String,callable:String):void
		{
			var button:StoreNavBar = new StoreNavBar(width, 28, initialText);
			button.roundRectStyle = new RoundRectStyle(10, 10);
			button.labelFormat = new TextFormat('EuroStyle', 20, 0x9D330B, true);
			button.buttonMode = true;
			if (callable == "onPlayAgainClick")
			{
				button.addEventListener(MouseEvent.CLICK, onPlayAgainClick);
			}
			else
			{
				button.addEventListener(MouseEvent.CLICK, onCloseToWorldClick);
			}
			button.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			this.rawChildren.addChild(button);
			
			button.labelX = button.width/2 - button.labelWidth/2;

			setDefaultButton(button);
				
			button.x = x;
			button.y = y;
				
			function onButtonMouseOver(event:MouseEvent):void
			{
				setMouseOverButton(event.currentTarget);
			}
				
			function onButtonMouseOut(event:MouseEvent):void
			{
				setDefaultButton(event.currentTarget);
			}
			
			function onPlayAgainClick(event:MouseEvent):void
			{
				// Remove Listeners
				button.removeEventListener(MouseEvent.CLICK, onPlayAgainClick);
				button.removeEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
				button.removeEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
				
				// Set New Appearance
				setMouseOverButton(event.currentTarget);
					
				// Change Text
				button.label = onClickText;
				button.labelX = button.width/2 - button.labelWidth/2;
				
				closeToChallengeScreen();
			}
				
			function onCloseToWorldClick(event:MouseEvent):void
			{
				// Remove Listeners
				button.removeEventListener(MouseEvent.CLICK, onCloseToWorldClick);
				button.removeEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
				button.removeEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
					
				// Set New Appearance
				setMouseOverButton(event.currentTarget);
					
				// Change Text
				button.label = onClickText;
				
				closeToWorld();
			}
			
			function setDefaultButton(button:StoreNavBar):void
			{
				button.labelColor = 0x9D330B;
				button.borderStyle = new LineStyle(0x913300, 1, 1);
				
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
				button.gradient = new GradientStyle(GradientType.LINEAR, [0xF7D85B, 0xD88616], [1, 1], [0, 255], gradientBoxMatrix);
			}
				
			function setMouseOverButton(button:StoreNavBar):void
			{
				button.labelColor = 0xffcc33;
				button.borderStyle = new LineStyle(0xff9900, 1, 1);
				
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
				button.gradient = new GradientStyle(GradientType.LINEAR, [0xd18500, 0xa54c0a], [1, 1], [0, 255], gradientBoxMatrix);
			}
		}
		
		/////////////////////////////////////
		// UTILS
		/////////////////////////////////////
		
		private function intToRank(value:String):String
		{
			var intValue:int = parseInt(value);
			
			switch (intValue)
			{
				case 1:
					return "Amateur";
				case 2:
					return "Rookie";
				case 3:
					return "Pro";
				case 4:
					return "Veteran";
				case 5:
					return "All Star";
				default:
					return "N/A"
			}
		}
		
		/////////////////////////////////////
		// CLOSING THE WINDOW
		/////////////////////////////////////
		
		public function closeToChallengeScreen():void
		{
			dispatchEvent(new ChallengesEvent(parseInt(_gameId)));
			this.close();
		}
		
		public function closeToWorld():void
		{
			_storeIcon.removeEventListener(MouseEvent.CLICK,onStoreClick);
			
			this.close();
		}
		
		public function close():void
		{
			_storeIcon.removeEventListener(MouseEvent.CLICK,onStoreClick);
			
			PopUpManager.removePopUp(this);
		}
	}
}
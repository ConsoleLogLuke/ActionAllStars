package com.sdg.game.views
{
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.IGameMenuModel;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class FinalScoreView extends SubMenuViewBase
	{
		private const GRADIENT_WIDTH:int = 500;
		private const GRADIENT_HEIGHT:int = 110;
		private const SCORE_GAP:int = 85;
		private const REWARDS_GAP:int = 70;
		private const LOGO_WIDTH:int = 300;
		private const LOGO_HEIGHT:int = 400;
		
		private var _myTeamLogo:TeamLogoDisplay;
		private var _opponentTeamLogo:TeamLogoDisplay;
		private var _avatarNameText:TextField;
		private var _opponentText:TextField;
		private var _myScoreText:TextField;
		private var _opponentScoreText:TextField;
		private var _tokensValueText:TextField;
		private var _xpValueText:TextField;
		private var _winnerText:TextField;
		private var _finishedButton:DisplayObject;
		
		public function FinalScoreView()
		{
			super();
			
			_headerText = "Final Score";
			
			var finishedButton:QuickLoader = new QuickLoader("assets/swfs/nbaAllStars/Button_Finish.swf", onFinishLoaded);
			
			var rewardsGradient:Sprite = new Sprite();
			
			var updownGradient:Sprite = new Sprite();
			rewardsGradient.addChild(updownGradient);
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(GRADIENT_WIDTH, GRADIENT_HEIGHT, Math.PI/2, 0, 0);
			
			updownGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x363636, 0x1B1B1B], [1, 1], [0, 255], gradientBoxMatrix);
			updownGradient.graphics.drawRect(0, 0, GRADIENT_WIDTH, GRADIENT_HEIGHT);
			updownGradient.graphics.endFill();
			updownGradient.graphics.lineStyle(1, 0x535353);
			updownGradient.graphics.moveTo(0, 0);
			updownGradient.graphics.lineTo(GRADIENT_WIDTH, 0);
			updownGradient.cacheAsBitmap = true;
			
			var fadeOutGradient:Sprite = new Sprite();
			rewardsGradient.addChild(fadeOutGradient);
			
			var gradientBoxMatrix2:Matrix = new Matrix();
			gradientBoxMatrix2.createGradientBox(GRADIENT_WIDTH, GRADIENT_HEIGHT, 0, 0, 0);
			
			fadeOutGradient.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0xffffff, 0xffffff],
														[0, 1, 1, 0], [0, 60, 195, 255], gradientBoxMatrix2);
			fadeOutGradient.graphics.drawRect(0, 0, GRADIENT_WIDTH, GRADIENT_HEIGHT);
			fadeOutGradient.graphics.endFill();
			fadeOutGradient.cacheAsBitmap = true;
			
			updownGradient.mask = fadeOutGradient;
			
			addChild(rewardsGradient);
			rewardsGradient.x = 925/2 - GRADIENT_WIDTH/2;
			rewardsGradient.y = 360;
			
			var tokensText:TextField = new TextField();
			tokensText.defaultTextFormat = new TextFormat("EuroStyle", 15, 0x666666, true);
			tokensText.embedFonts = true;
			tokensText.autoSize = TextFieldAutoSize.LEFT;
			tokensText.selectable = false;
			addChild(tokensText);
			tokensText.text = "Tokens";
			tokensText.x = 925/2 - REWARDS_GAP - tokensText.width/2;
			tokensText.y = 366;
			
			var xpText:TextField = new TextField();
			xpText.defaultTextFormat = new TextFormat("EuroStyle", 15, 0x666666, true);
			xpText.embedFonts = true;
			xpText.autoSize = TextFieldAutoSize.LEFT;
			xpText.selectable = false;
			addChild(xpText);
			xpText.text = "Experience Points";
			xpText.x = 925/2 + REWARDS_GAP - xpText.width/2;
			xpText.y = 366;
			
			var rewardsText:TextField = new TextField();
			rewardsText.defaultTextFormat = new TextFormat("EuroStyle", 26, 0x666666, true);
			rewardsText.embedFonts = true;
			rewardsText.autoSize = TextFieldAutoSize.LEFT;
			rewardsText.selectable = false;
			addChild(rewardsText);
			rewardsText.text = "Rewards Earned";
			rewardsText.x = 925/2 - rewardsText.width/2;
			rewardsText.y = 426;
			
			function onFinishLoaded():void
			{
				_finishedButton = finishedButton.content;
				addChild(_finishedButton);
				_finishedButton.x = 925/2 - _finishedButton.width/2;
				_finishedButton.y = 665 - 20 - _finishedButton.height;
				_finishedButton.addEventListener(MouseEvent.CLICK, onFinishClick, false, 0, true);
			}
		}
		
		private function onFinishClick(event:MouseEvent):void
		{
			dispatchEvent(new UnityNBAEvent(UnityNBAEvent.FINAL_SCORE_FINISH_CLICK, true));
		}
		
		private function setupFinalScreen():void
		{
			if (_myTeamLogo == null)
			{
				_myTeamLogo = new TeamLogoDisplay(_model.myTeam, LOGO_WIDTH, LOGO_HEIGHT, true);
				addChild(_myTeamLogo);
				_myTeamLogo.filters = [new GlowFilter(0xffffff, 1, 5, 5, 10)];
				_myTeamLogo.x = 10;
				_myTeamLogo.y = 665/2 - LOGO_HEIGHT/2;
			}
			else
			{
				_myTeamLogo.refresh();
			}
			
			if (_opponentTeamLogo == null)
			{
				_opponentTeamLogo = new TeamLogoDisplay(_model.opponentTeam, LOGO_WIDTH, LOGO_HEIGHT, true);
				addChild(_opponentTeamLogo);
				_opponentTeamLogo.filters = [new GlowFilter(0xffffff, 1, 5, 5, 10)];
				_opponentTeamLogo.x = 925 - 10 - LOGO_WIDTH;
				_opponentTeamLogo.y = 665/2 - LOGO_HEIGHT/2;
			}
			else
			{
				_opponentTeamLogo.refresh();
			}
			
			if (_avatarNameText == null)
			{
				_avatarNameText = new TextField();
				_avatarNameText.defaultTextFormat = new TextFormat("EuroStyle", 21, 0xffffff, true);
				_avatarNameText.embedFonts = true;
				_avatarNameText.autoSize = TextFieldAutoSize.LEFT;
				_avatarNameText.selectable = false;
				addChild(_avatarNameText);
			}
			_avatarNameText.text = ModelLocator.getInstance().avatar.name;
			_avatarNameText.x = 925/2 - SCORE_GAP - _avatarNameText.width/2;
			_avatarNameText.y = 236;
			
			if (_opponentText == null)
			{
				_opponentText = new TextField();
				_opponentText.defaultTextFormat = new TextFormat("EuroStyle", 21, 0xffffff, true);
				_opponentText.embedFonts = true;
				_opponentText.autoSize = TextFieldAutoSize.LEFT;
				_opponentText.selectable = false;
				addChild(_opponentText);
			}
			_opponentText.text = "Opponent";
			_opponentText.x = 925/2 + SCORE_GAP - _opponentText.width/2;
			_opponentText.y = 236;
			
			if (_myScoreText == null)
			{
				_myScoreText = new TextField();
				_myScoreText.defaultTextFormat = new TextFormat("EuroStyle", 52, 0xffffff, true);
				_myScoreText.embedFonts = true;
				_myScoreText.autoSize = TextFieldAutoSize.LEFT;
				_myScoreText.selectable = false;
				addChild(_myScoreText);
			}
			_myScoreText.text = _model.myScore.toString();
			_myScoreText.x = 925/2 - SCORE_GAP - _myScoreText.width/2;
			_myScoreText.y = 264;
			
			if (_opponentScoreText == null)
			{
				_opponentScoreText = new TextField();
				_opponentScoreText.defaultTextFormat = new TextFormat("EuroStyle", 52, 0xffffff, true);
				_opponentScoreText.embedFonts = true;
				_opponentScoreText.autoSize = TextFieldAutoSize.LEFT;
				_opponentScoreText.selectable = false;
				addChild(_opponentScoreText);
			}
			_opponentScoreText.text = _model.opponentScore.toString();
			_opponentScoreText.x = 925/2 + SCORE_GAP - _opponentScoreText.width/2;
			_opponentScoreText.y = 264;
			
			if (_tokensValueText == null)
			{
				_tokensValueText = new TextField();
				_tokensValueText.defaultTextFormat = new TextFormat("EuroStyle", 30, 0xffffff, true);
				_tokensValueText.embedFonts = true;
				_tokensValueText.autoSize = TextFieldAutoSize.LEFT;
				_tokensValueText.selectable = false;
				addChild(_tokensValueText);
				_tokensValueText.filters = [new GlowFilter(0x0594D3, 1, 8, 8, 2, 3)];
			}
			_tokensValueText.text = _model.tokensEarned.toString();
			_tokensValueText.x = 925/2 - REWARDS_GAP - _tokensValueText.width/2;
			_tokensValueText.y = 387;
			
			if (_xpValueText == null)
			{
				_xpValueText = new TextField();
				_xpValueText.defaultTextFormat = new TextFormat("EuroStyle", 30, 0xffffff, true);
				_xpValueText.embedFonts = true;
				_xpValueText.autoSize = TextFieldAutoSize.LEFT;
				_xpValueText.selectable = false;
				addChild(_xpValueText);
				_xpValueText.filters = [new GlowFilter(0x0594D3, 1, 8, 8, 2, 3)];
			}
			_xpValueText.text = _model.xpEarned.toString();
			_xpValueText.x = 925/2 + REWARDS_GAP - _xpValueText.width/2;
			_xpValueText.y = 387;
			
			if (_winnerText == null)
			{
				_winnerText = new TextField();
				_winnerText.defaultTextFormat = new TextFormat("EuroStyle", 52, 0xffffff, true);
				_winnerText.embedFonts = true;
				_winnerText.autoSize = TextFieldAutoSize.LEFT;
				_winnerText.selectable = false;
				addChild(_winnerText);
			}
			
			if (_model.isWinner)
			{
				_winnerText.text = "You Win";
			}
			else
			{
				if (_model.myScore == _model.opponentScore)
				{
					_winnerText.text = "You Tied";
				}
				else
				{
					_winnerText.text = "You Lose";
				}
			}
			
			_winnerText.x = 925/2 - _winnerText.width/2;
			_winnerText.y = 500;
		}
		
		override public function close():void
		{
			if (_finishedButton)
				_finishedButton.removeEventListener(MouseEvent.CLICK, onFinishClick);
			
			super.close();
		}
		
		override protected function refresh():void
		{
			if (_isModelDirty == true)
			{
				setupFinalScreen();
			}
			
			super.refresh();
		}
		
		override protected function onDataChange(event:UnityNBAEvent):void
		{
			super.onDataChange(event);
			setupFinalScreen();
		}
	}
}
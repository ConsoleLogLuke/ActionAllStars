package com.sdg.game.views
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.UnityNBAPlayer;
	import com.sdg.game.models.UnityNBATeam;
	import com.sdg.game.models.UnityNBATier;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class PickYourTeamView extends SubMenuViewBase
	{
		private const ANIMATION_PAN_LEFT:String = "animation pan left";
		private const ANIMATION_PAN_RIGHT:String = "animation pan right";
		private const LOGO_WIDTH:Number = 440;
		private const LOGO_HEIGHT:Number = 460;
		
		private var _index:int;
		private var _logoContainer:Sprite;
		private var _availableTeams:Array;
		private var _currentTeamLogoDisplay:TeamLogoDisplay;
		private var _leftArrow:DisplayObject;
		private var _rightArrow:DisplayObject;
		private var _finishButton:DisplayObject;
		private var _animationManager:AnimationManager;
		private var _playerMeter:DisplayObject;
		
		public function PickYourTeamView()
		{
			super();
			
			_logoContainer = new Sprite();
			addChild(_logoContainer);
			_logoContainer.y = 317 - LOGO_HEIGHT/2;
			
			_leftArrow = new QuickLoader("assets/swfs/nbaAllStars/LeftButton.swf", onLeftComplete);
			addChild(_leftArrow);
			_leftArrow.addEventListener(MouseEvent.CLICK, onLeftArrowClick, false, 0, true);
			
			_rightArrow = new QuickLoader("assets/swfs/nbaAllStars/RightButton.swf", onRightComplete);
			addChild(_rightArrow);
			_rightArrow.addEventListener(MouseEvent.CLICK, onRightArrowClick, false, 0, true);
			
			_finishButton = new QuickLoader("assets/swfs/nbaAllStars/Button_Select.swf", onFinishComplete);
			addChild(_finishButton);
			_finishButton.addEventListener(MouseEvent.CLICK, onFinishClick, false, 0, true);
			
			_headerText = "Pick Your Team";
			
			var unlockText:TextField = new TextField();
			unlockText.defaultTextFormat = new TextFormat('EuroStyle', 20, 0xffffff, true);
			unlockText.embedFonts = true;
			unlockText.autoSize = TextFieldAutoSize.LEFT;
			unlockText.selectable = false;
			unlockText.text = "You can unlock more teams by winning games. Good Luck!";
			addChild(unlockText);
			unlockText.x = 925/2 - unlockText.width/2;
			unlockText.y = 100;
			
			
			function onLeftComplete():void
			{
				_leftArrow.x = 925/2 - 300 - _leftArrow.width/2;
				_leftArrow.y = 210;
			}
			
			function onRightComplete():void
			{
				_rightArrow.x = 925/2 + 300 - _rightArrow.width/2;
				_rightArrow.y = 210;
			}
			
			function onFinishComplete():void
			{
				_finishButton.x = 925/2 - _finishButton.width/2;
				_finishButton.y = 665 - 20 - _finishButton.height;
			}
		}
		
		override public function close():void
		{
			if (_leftArrow)
				_leftArrow.removeEventListener(MouseEvent.CLICK, onLeftArrowClick);
			
			if (_rightArrow)
				_rightArrow.removeEventListener(MouseEvent.CLICK, onRightArrowClick);
			
			if (_finishButton)
				_finishButton.removeEventListener(MouseEvent.CLICK, onFinishClick);
			
			if (_animationManager != null)
				_animationManager.dispose();
			
			super.close();
		}
		
		private function setPlayerMeters(player1:UnityNBAPlayer, player2:UnityNBAPlayer):void
		{
			var meterLoader:QuickLoader;
			
			if (_playerMeter == null)
			{
				meterLoader = new QuickLoader("assets/swfs/nbaAllStars/unity_nbaMenuMeters.swf", onMeterLoaded);
			}
			else
			{
				setMeter();
			}
			
			function onMeterLoaded():void
			{
				_playerMeter = meterLoader.content;
				addChildAt(_playerMeter, 0);
				_playerMeter.y = 665 - _playerMeter.height - 20;
				
				setMeter();
			}
			
			function setMeter():void
			{
				var p1:Object = {name:player1.name, attributes:player1.attributes};
				var p2:Object = {name:player2.name, attributes:player2.attributes};
				
				Object(_playerMeter).tsSelectView.setTeam({p1:p1, p2:p2});
			}
		}
		
		private function onFinishClick(event:MouseEvent):void
		{
			_model.myTeam = _availableTeams[_index];
			dispatchEvent(new UnityNBAEvent(UnityNBAEvent.MY_TEAM_VIEW_DONE, true));
		}
		
		private function onLeftArrowClick(event:MouseEvent):void
		{
			var numTeams:int = _availableTeams.length;
			
			if (numTeams == 0) return;
			_index--;
			if (_index < 0)
				_index = numTeams - 1;
			
			showTeamByIndex(ANIMATION_PAN_LEFT);
		}
		
		private function onRightArrowClick(event:MouseEvent):void
		{
			var numTeams:int = _availableTeams.length;
			
			if (numTeams == 0) return;
			_index++;
			if (_index > numTeams - 1)
				_index = 0;
			
			showTeamByIndex(ANIMATION_PAN_RIGHT);
		}
		
		private function animateProperty(target:Object, property:String, targetValue:Number, duration:Number):void
		{
			if (_animationManager == null)
				_animationManager = new AnimationManager();
			
			_animationManager.property(target, property, targetValue, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function showTeamByIndex(animationMethod:String = null):void
		{
			var indexTeam:UnityNBATeam;
			var teamLogoDisplay:TeamLogoDisplay;
			var logoDisplayForRemoval:TeamLogoDisplay;
			
			if (_availableTeams != null)
				indexTeam = _availableTeams[_index];
			
			if (indexTeam == null)
			{
				if (_index != 0)
				{
					// try index 0
					_index = 0;
					showTeamByIndex();
					return;
				}
				
				if (_currentTeamLogoDisplay != null)
				{
					logoDisplayForRemoval = _currentTeamLogoDisplay;
					removeCurrentLogoDisplay();
				}
			}
			else
			{
				if (_currentTeamLogoDisplay != null)
				{
					if (indexTeam == _currentTeamLogoDisplay.team)
					{
						_currentTeamLogoDisplay.refresh();
						return;
					}
					
					logoDisplayForRemoval = _currentTeamLogoDisplay;
				}
				
				teamLogoDisplay = new TeamLogoDisplay(indexTeam, LOGO_WIDTH, LOGO_HEIGHT);
				_logoContainer.addChild(teamLogoDisplay);
				teamLogoDisplay.filters = [new GlowFilter(0xffffff, 1, 5, 5, 10)];
				var players:Array = indexTeam.players;
				setPlayerMeters(players[0], players[1]);
				
				positionLogo();
			}
			
			_currentTeamLogoDisplay = teamLogoDisplay;
			
			
			function positionLogo():void
			{
				if (animationMethod == null)
				{
					teamLogoDisplay.x = 925/2 - LOGO_WIDTH/2;
					return;
				}
				
				teamLogoDisplay.alpha = 0;
				var removalLogoFinalX:int;
				
				if (animationMethod == ANIMATION_PAN_LEFT)
				{
					teamLogoDisplay.x = 925 + 100;
					removalLogoFinalX = -LOGO_WIDTH - 100;
				}
				else if (animationMethod == ANIMATION_PAN_RIGHT)
				{
					teamLogoDisplay.x = -LOGO_WIDTH - 100;
					removalLogoFinalX = 925 + 100;
				}
				
				if (logoDisplayForRemoval != null)
				{
					animateProperty(logoDisplayForRemoval, "x", removalLogoFinalX, 300);
					animateProperty(logoDisplayForRemoval, "alpha", 0, 300);
				}
				
				animateProperty(teamLogoDisplay, "x", 925/2 - LOGO_WIDTH/2, 300);
				animateProperty(teamLogoDisplay, "alpha", 1, 300);
				_animationManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			}
			
			function onAnimFinish(event:AnimationEvent):void
			{
				_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				
				if (logoDisplayForRemoval != null)
				{
					removeCurrentLogoDisplay();
				}
			}
			
			function removeCurrentLogoDisplay():void
			{
				logoDisplayForRemoval.destroy();
				_logoContainer.removeChild(logoDisplayForRemoval);
			}
		}
		
		private function updateAvailableTeams():void
		{
			if (_model == null) return;
			
			for each (var tier:UnityNBATier in _model.tierArray)
			{
				if (tier.locked == false)
				{
					for each (var team:UnityNBATeam in tier.teams)
					{
						_availableTeams.push(team);
					}
				}
			}
		}
		
		override protected function refresh():void
		{
			if (_isModelDirty == true)
			{
				_availableTeams = new Array();
				updateAvailableTeams();
			}
			
			showTeamByIndex();
			
			super.refresh();
		}
		
		override protected function onDataChange(event:UnityNBAEvent):void
		{
			super.onDataChange(event);
			updateAvailableTeams();
			showTeamByIndex();
		}
	}
}
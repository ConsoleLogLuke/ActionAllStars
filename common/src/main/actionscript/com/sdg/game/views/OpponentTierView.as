package com.sdg.game.views
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.IGameMenuModel;
	import com.sdg.game.models.UnityNBATier;
	import com.sdg.net.QuickLoader;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class OpponentTierView extends SubMenuViewBase
	{
		private var _tierDisplayArray:Array;
		private var _tierContainer:Sprite;

		private var _selectedTier:TierDisplay;
		private var _animationManager:AnimationManager;
		private var _mask:Sprite;
		private var _selectedTeam:OpponentTeamDisplay;
		private var _startGameButton:DisplayObject;
		private var _backButton:DisplayObject;

		public function OpponentTierView()
		{
			super();

			var startGameButton:QuickLoader = new QuickLoader("swfs/nbaAllStars/Button_StartGame.swf", onStartGameLoaded);
			var backButton:QuickLoader = new QuickLoader("swfs/nbaAllStars/Button_Back.swf", onBackLoaded);

			_headerText = "Pick Opponent";

			function onStartGameLoaded():void
			{
				_startGameButton = startGameButton.content;
				addChild(_startGameButton);
				_startGameButton.x = 925/2 - _startGameButton.width/2;
				_startGameButton.y = 665 - 20 - _startGameButton.height;
				_startGameButton.addEventListener(MouseEvent.CLICK, onStartGameClick, false, 0, true);
			}

			function onBackLoaded():void
			{
				_backButton = backButton.content;
				addChild(_backButton);
				_backButton.x = 25;
				_backButton.y = 665 - 30 - _backButton.height;
				_backButton.addEventListener(MouseEvent.CLICK, onBackClick, false, 0, true);
			}
		}

		override public function close():void
		{
			if (_startGameButton)
				_startGameButton.removeEventListener(MouseEvent.CLICK, onStartGameClick);

			if (_backButton)
				_backButton.removeEventListener(MouseEvent.CLICK, onBackClick);

			if (_tierContainer)
				_tierContainer.removeEventListener(UnityNBAEvent.OPPONENT_TEAM_SELECTED, onOpponentTeamSelected);

			// clean slate
			cleanSlate();

			if (_animationManager != null)
				_animationManager.dispose();

			super.close();
		}

		private function onBackClick(event:MouseEvent):void
		{
			dispatchEvent(new UnityNBAEvent(UnityNBAEvent.BACK_BUTTON_CLICK, true));
		}

		private function onStartGameClick(event:MouseEvent):void
		{
			_model.opponentTeam = _selectedTeam.team;

			dispatchEvent(new UnityNBAEvent(UnityNBAEvent.START_GAME, true));
		}

		private function cleanSlate():void
		{
			var tierDisplay:TierDisplay;

			for each (tierDisplay in _tierDisplayArray)
			{
				tierDisplay.destroy();
				tierDisplay.removeEventListener(MouseEvent.CLICK, onTierClick);
				_tierContainer.removeChild(tierDisplay);
			}
		}

		private function createTiers():void
		{
			var index:int;
			var arraylength:int;
			var tierDisplay:TierDisplay;

			// clean slate
			cleanSlate();

			if (_tierContainer == null)
			{
				_tierContainer = new Sprite();
				_tierContainer.addEventListener(UnityNBAEvent.OPPONENT_TEAM_SELECTED, onOpponentTeamSelected, false, 0, true);
				addChild(_tierContainer);
				_tierContainer.x = 925/2 - 885/2;
				_tierContainer.y = 125;
			}

			if (_tierDisplayArray == null)
			{
				_tierDisplayArray = new Array();
			}

			var highestUnlockedTier:TierDisplay;
			var tier:UnityNBATier;
			var numTiers:int = 0;

			arraylength = _model.tierArray.length;
			for (index = 0; index < arraylength; index++)
			{
				tier = _model.tierArray[index];
				if (tier == null) continue;
				tierDisplay = new TierDisplay(index, tier);
				tierDisplay.addEventListener(MouseEvent.CLICK, onTierClick, false, 0, true);
				_tierContainer.addChildAt(tierDisplay, 0);
				_tierDisplayArray[index] = tierDisplay;
				numTiers++;

				tierDisplay.y = ((arraylength - 1) - index) * 40;

				if (tier.locked == false)
				{
					highestUnlockedTier = tierDisplay;
				}
			}

			selectedTier = highestUnlockedTier;
			highestUnlockedTier.notDefeatedTeam.selected = true;

			if (_mask == null)
			{
				_mask = new Sprite();
				_tierContainer.addChild(_mask);
				_tierContainer.mask = _mask;
			}

			_mask.graphics.clear();
			_mask.graphics.beginFill(0xffffff);
			_mask.graphics.drawRect(0, 0, 885, numTiers * 40 + 190);
		}



		private function onOpponentTeamSelected(event:UnityNBAEvent):void
		{
			if (_selectedTeam != null)
			{
				_selectedTeam.selected = false;
			}

			_selectedTeam = event.target as OpponentTeamDisplay;
		}

		private function onTierClick(event:MouseEvent):void
		{
			selectedTier = event.currentTarget as TierDisplay;
		}

		private function animateProperty(target:Object, property:String, targetValue:Number, duration:Number):void
		{
			if (_animationManager == null)
				_animationManager = new AnimationManager();

			_animationManager.property(target, property, targetValue, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}

		private function updateTiers():void
		{
			if (_selectedTier != null)
			{
				_selectedTier.show();
			}
		}

		private function set selectedTier(value:TierDisplay):void
		{
			var previousTierIndex:int;
			var currentTierIndex:int;
			var index:int;
			var tier:TierDisplay;

			if (value == _selectedTier) return;

			if (_selectedTier != null)
			{
				_selectedTier.hide();
				previousTierIndex = _selectedTier.tierIndex;
			}

			_selectedTier = value;

			if (_selectedTier != null)
			{
				_selectedTier.show();
				currentTierIndex = _selectedTier.tierIndex;
			}

			var arraylength:int = _model.tierArray.length;

			if (previousTierIndex < currentTierIndex)
			{
				for (index = previousTierIndex; index < currentTierIndex; index++)
				{
					tier = _tierDisplayArray[index];
					if (tier == null) continue;
					animateProperty(tier, "y", ((arraylength - 1) - index) * 40 + 190, 300);
				}
			}
			else
			{
				for (index = currentTierIndex; index < previousTierIndex; index++)
				{
					tier = _tierDisplayArray[index];
					if (tier == null) continue;
					animateProperty(tier, "y", ((arraylength - 1) - index) * 40, 300);
				}
			}
		}

		override protected function refresh():void
		{
			if (_isModelDirty == true)
			{
				createTiers();
			}
			else
			{
				updateTiers();
			}

			super.refresh();
		}

		override protected function onDataChange(event:UnityNBAEvent):void
		{
			super.onDataChange(event);
			createTiers();
		}
	}
}

package com.sdg.game.views
{
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.IGameMenuModel;
	import com.sdg.game.models.IUnityNBAModel;
	import com.sdg.net.QuickLoader;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class UnityNBAView extends Sprite implements IUnityNBAView
	{
		private var _model:IUnityNBAModel;
		private var _currentSubMenu:ISubMenuView;
		private var _pickYourTeamView:PickYourTeamView;
		private var _pickYourOpponentView:OpponentTierView;
		private var _finalScoreView:FinalScoreView;
		private var _quitButton:DisplayObject;
		private var _viewHeader:TextField;

		public function UnityNBAView()
		{
			super();

			var background:QuickLoader = new QuickLoader("swfs/nbaAllStars/nbaBackground.swf", onBackgroundLoaded);
			var quitButton:QuickLoader = new QuickLoader("swfs/nbaAllStars/Button_Quit.swf", onQuitLoaded);

			_viewHeader = new TextField();
			_viewHeader.defaultTextFormat = new TextFormat('EuroStyle', 50, 0x000000, true);
			_viewHeader.embedFonts = true;
			_viewHeader.autoSize = TextFieldAutoSize.LEFT;
			_viewHeader.selectable = false;
			_viewHeader.filters = [new GlowFilter(0xffffff, 1, 10, 10, 10)];
			addChild(_viewHeader);
			_viewHeader.y = 40;

			currentSubMenu = pickYourTeamView;

			function onBackgroundLoaded():void
			{
				addChildAt(background.content, 0);
			}

			function onQuitLoaded():void
			{
				_quitButton = quitButton.content;
				addChild(_quitButton);
				_quitButton.x = 925 - 15 - _quitButton.width;
				_quitButton.y = 15;

				_quitButton.addEventListener(MouseEvent.CLICK, onQuitClick, false, 0, true);
			}
		}

		public function close():void
		{
			_quitButton.removeEventListener(MouseEvent.CLICK, onQuitClick);

			if (_model)
				_model.removeEventListener(UnityNBAEvent.GAME_RESULT, onGameResult);

			if (_pickYourTeamView)
			{
				_pickYourTeamView.addEventListener(UnityNBAEvent.MY_TEAM_VIEW_DONE, onMyTeamPicked);
				_pickYourTeamView.close();
			}

			if (_pickYourOpponentView)
			{
				_pickYourOpponentView.addEventListener(UnityNBAEvent.BACK_BUTTON_CLICK, onBackButtonClick);
				_pickYourOpponentView.close();
			}

			if (_finalScoreView)
			{
				_finalScoreView.addEventListener(UnityNBAEvent.FINAL_SCORE_FINISH_CLICK, onFinalScoreFinishClick);
				_finalScoreView.close();
			}
		}

		private function onQuitClick(event:MouseEvent):void
		{
			quitGame();
		}

		public function set model(value:IGameMenuModel):void
		{
			if (value == _model) return;

			if (_model != null)
			{
				// remove event listeners
				_model.removeEventListener(UnityNBAEvent.GAME_RESULT, onGameResult);
			}

			_model = value as IUnityNBAModel;

			if (_currentSubMenu != null)
				_currentSubMenu.show(_model);

			// add event listeners
			_model.addEventListener(UnityNBAEvent.GAME_RESULT, onGameResult, false, 0, true);
		}

		private function quitGame():void
		{
			dispatchEvent(new UnityNBAEvent(UnityNBAEvent.QUIT_GAME, true));
		}

		private function onGameResult(event:UnityNBAEvent):void
		{
			if (_model.isGameComplete)
			{
				currentSubMenu = finalScoreView;
			}
			else
			{
				quitGame();
			}
		}

		private function get pickYourTeamView():PickYourTeamView
		{
			if (_pickYourTeamView == null)
			{
				_pickYourTeamView = new PickYourTeamView();

				// add event listeners
				_pickYourTeamView.addEventListener(UnityNBAEvent.MY_TEAM_VIEW_DONE, onMyTeamPicked, false, 0, true);
			}

			return _pickYourTeamView;
		}

		private function onMyTeamPicked(event:UnityNBAEvent):void
		{
			currentSubMenu = pickYourOpponentView;
		}

		private function get finalScoreView():FinalScoreView
		{
			if (_finalScoreView == null)
			{
				_finalScoreView = new FinalScoreView();

				// add event listeners
				_finalScoreView.addEventListener(UnityNBAEvent.FINAL_SCORE_FINISH_CLICK, onFinalScoreFinishClick, false, 0, true);
			}

			return _finalScoreView;
		}

		private function get pickYourOpponentView():OpponentTierView
		{
			if (_pickYourOpponentView == null)
			{
				_pickYourOpponentView = new OpponentTierView();

				// add event listeners
				_pickYourOpponentView.addEventListener(UnityNBAEvent.BACK_BUTTON_CLICK, onBackButtonClick, false, 0, true);
			}

			return _pickYourOpponentView;
		}

		private function onFinalScoreFinishClick(event:UnityNBAEvent):void
		{
			quitGame();
		}

		private function onBackButtonClick(event:UnityNBAEvent):void
		{
			currentSubMenu = pickYourTeamView;
		}

		private function setViewHeader():void
		{
			_viewHeader.text = _currentSubMenu.headerText;
			_viewHeader.x = 925/2 - _viewHeader.width/2;
		}

		private function set currentSubMenu(value:ISubMenuView):void
		{
			if (value == _currentSubMenu) return;

			if (_currentSubMenu != null)
			{
				//remove event listeners

				// close out current menu
				_currentSubMenu.hide();

				// remove old menu
				removeChild(_currentSubMenu as DisplayObject);
			}

			_currentSubMenu = value;
			addChild(value as DisplayObject);
			value.show(_model);
			setViewHeader();
		}
	}
}

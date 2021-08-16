package com.sdg.leaderboard
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.good.goodui.FluidView;
	import com.sdg.controls.TabListControl;
	import com.sdg.events.AvatarEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.UserTitleBlockEvent;
	import com.sdg.leaderboard.list.LeaderboardUserListControl;
	import com.sdg.leaderboard.model.TopUser;
	import com.sdg.leaderboard.model.TopUserCollection;
	import com.sdg.leaderboard.view.AllStarHallView;
	import com.sdg.leaderboard.view.LeaderboardGameSelector;
	import com.sdg.leaderboard.view.LeaderboardUserCard;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.QuickLoader;
	import com.sdg.ui.CandyCloseButton;
	import com.sdg.util.AssetUtil;
	import com.sdg.util.ServerFeedUtil;
	import com.sdg.view.ViewSlider;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;


	public class Leaderboard extends FluidView
	{
		public static const GAMER:uint = 3;
		public static const GURU:uint = 4;
		public static const COLLECTOR:uint = 5;
		public static const GAMER_NAME:String = 'GAMER';
		public static const GURU_NAME:String = 'GURU';
		public static const COLLECTOR_NAME:String = 'COLLECTOR';
		protected static const _BACKGROUND_URL:String = AssetUtil.GetGameAssetUrl(74, 'background.swf');
		protected static const _GAME_ID_MAP:Object = {};
		
		protected var _back:Sprite;
		protected var _mask:Sprite;
		protected var _outline:Sprite;
		protected var _tabControl:TabListControl;
		protected var _userListControl:LeaderboardUserListControl;
		protected var _userCard:LeaderboardUserCard;
		protected var _gameSelector:LeaderboardGameSelector;
		protected var _listLoader:URLLoader;
		protected var _animManager:AnimationManager;
		protected var _userListContainer:Sprite;
		protected var _userListMask:Sprite;
		protected var _loadIndicator:Sprite;
		protected var _games:Array;
		protected var _currentGameListIds:Array;
		protected var _currentGameId:uint;
		protected var _selectorContainer:Sprite;
		protected var _selectorMask:Sprite;
		protected var _useNewUserListFlag:Boolean;
		protected var _listLimit:uint;
		protected var _allStarHallView:AllStarHallView;
		protected var _leaderboardContainer:Sprite;
		protected var _viewSlider:ViewSlider;
		protected var _currentGameListId:uint;
		protected var _userId:uint;
		protected var _closeBtn:CandyCloseButton;
		protected var _isLoadingUserCard:Boolean;
		protected var _quedSelectedUserId:int;
		
		private var gameIds:Object=new Object();
		

		public function Leaderboard(avatarId:uint,gameTypeIdIn:uint = 0,startIndexIn:uint = 0)
		{
			super(860, 600);

		gameIds[3]=LoggingUtil.LEADER_GAMER_XP_BUTTON;
		gameIds[4]=LoggingUtil.LEADER_GURU_XP_BUTTON;
		gameIds[5]=LoggingUtil.LEADER_COLLECTOR_XP_BUTTON;
		gameIds[6]=LoggingUtil.LEADER_TURF_VALUE_BUTTON;
		gameIds[11]=LoggingUtil.LEADER_HOOPS_BUTTON;
		gameIds[12]=LoggingUtil.LEADER_SNOWBOARDING_BUTTON;
		gameIds[13]=LoggingUtil.LEADER_SURFING_BUTTON;
		gameIds[14]=LoggingUtil.LEADER_BLB_BUTTON;
		gameIds[15]=LoggingUtil.LEADER_THREE_BUTTON;
		gameIds[16]=LoggingUtil.LEADER_HANDLES_BUTTON;
		gameIds[17]=LoggingUtil.LEADER_PITCHING_ACE_BUTTON;
		gameIds[18]=LoggingUtil.LEADER_BATTER_PINBALL_BUTTON;
		gameIds[21]=LoggingUtil.LEADER_QBC_BUTTON;
		gameIds[100]=LoggingUtil.LEADER_TRIVIA_BUTTON;
		gameIds[101]=LoggingUtil.LEADER_SPORTS_PSYCHIC_BUTTON;
			
			var tabHeight:Number = 30;
			_animManager = new AnimationManager();
			_games = [];
			_GAME_ID_MAP[GAMER_NAME] = GAMER;
			_GAME_ID_MAP[GURU_NAME] = GURU;
			_GAME_ID_MAP[COLLECTOR_NAME] = COLLECTOR;
			_currentGameListIds = [];
			_currentGameId = 3;
			_useNewUserListFlag = false;
			_listLimit = 40;
			_userId = avatarId;
			
			_mask = new Sprite();
			_mask.graphics.beginFill(0x00ff00);
			drawContour(_mask.graphics);
			
			_back = new QuickLoader(_BACKGROUND_URL, render, null, 2);
			_back.mask = _mask;
			
			_outline = new Sprite();
			
			_tabControl = new TabListControl([GAMER_NAME, GURU_NAME, COLLECTOR_NAME, 'ALLSTAR HALL'], tabHeight, width);
			_tabControl.addEventListener(TabListControl.TAB_SELECT, onRootTabSelect);
			
			_userListControl = new LeaderboardUserListControl();
			_userListControl.addEventListener(LeaderboardUserListControl.TIME_FRAME_SELECT, onUserListTimeFrameSelect);
			_userListControl.addEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
			_userListControl.addEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
			_userListControl.addEventListener(UserTitleBlockEvent.USER_SELECT, onUserSelect);
			
			_userCard = new LeaderboardUserCard(300, 420);
			
			_selectorMask = new Sprite();
			
			_selectorContainer = new Sprite();
			_selectorContainer.mask = _selectorMask;
			
			_gameSelector = new LeaderboardGameSelector(_width - 20, _height - tabHeight - _userListControl.height - 30, startIndexIn);
			_gameSelector.addEventListener(LeaderboardGameSelector.ITEM_SELECT, onGameSelect);
			
			_userListMask = new Sprite();
			
			_userListContainer = new Sprite();
			_userListContainer.mask = _userListMask;
			
			_loadIndicator = new Sprite();
			var spinner:SpinningLoadingIndicator = new SpinningLoadingIndicator();
			_loadIndicator.graphics.beginFill(0, 0.7);
			_loadIndicator.graphics.drawRoundRect(0, 0, spinner.width * 1.5, spinner.height * 1.5, 10, 10);
			spinner.x = _loadIndicator.width / 2 - spinner.width / 2;
			spinner.y = _loadIndicator.height / 2 - spinner.height / 2;
			_loadIndicator.addChild(spinner);
			_loadIndicator.width = 100;
			_loadIndicator.height = 100;
			_loadIndicator.visible = false;
			
			_leaderboardContainer = new Sprite();
			
			_allStarHallView = new AllStarHallView(_width, _height);
			_allStarHallView.addEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
			
			_viewSlider = new ViewSlider(_width, _height, [_leaderboardContainer, _allStarHallView]);
			
			_closeBtn = new CandyCloseButton(26);
			_closeBtn.filters = [new DropShadowFilter(2, 45, 0, 1, 7, 7)];
			// We are hiding this close button in favor of the one used in the leaderboard module.
			_closeBtn.visible = false;
			
			addChild(_tabControl);
			addChild(_mask);
			addChild(_back);
			addChild(_viewSlider);
			addChild(_outline);
			addChild(_closeBtn);
			_leaderboardContainer.addChild(_userListContainer);
			_leaderboardContainer.addChild(_userListMask);
			_userListContainer.addChild(_userListControl);
			_leaderboardContainer.addChild(_selectorMask);
			_leaderboardContainer.addChild(_selectorContainer);
			_selectorContainer.addChild(_gameSelector);
			_leaderboardContainer.addChild(_userCard);
			_leaderboardContainer.addChild(_loadIndicator);
			
			render();
	
			// Load game list.
			if (gameTypeIdIn)
			{
				loadGameList(gameTypeIdIn);
			}
			else
			{
				loadGameList(GAMER);
			}
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function destroy():void
		{
			_userListControl.removeEventListener(LeaderboardUserListControl.TIME_FRAME_SELECT, onUserListTimeFrameSelect);
			_userListControl.removeEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
			_userListControl.removeEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
			_userListControl.removeEventListener(UserTitleBlockEvent.USER_SELECT, onUserSelect);
			_tabControl.removeEventListener(TabListControl.TAB_SELECT, onRootTabSelect);
			_closeBtn.removeEventListener(MouseEvent.CLICK, onCloseClick);
			_allStarHallView.removeEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			var tabHeight:Number = _tabControl.tabHeight;
			
			_mask.y = tabHeight;
			
			var bW:Number = _width;
			var bH:Number = _height - tabHeight;
			_back.width = bW;
			_back.height = bH;
			_back.y = tabHeight;
			
			_closeBtn.x = bW - _closeBtn.width / 2;
			_closeBtn.y = _back.y - _closeBtn.height / 2;
			_closeBtn.buttonMode = true;
			_closeBtn.addEventListener(MouseEvent.CLICK, onCloseClick);
			
			_outline.y = tabHeight;
			_outline.graphics.clear();
			_outline.graphics.lineStyle(3, 0x000000);
			drawContour(_outline.graphics);
			
			_viewSlider.y = tabHeight;
			
			_userListControl.x = 10;
			_userListControl.y = 10;
			
			_userListMask.graphics.clear();
			_userListMask.graphics.beginFill(0x00ff00);
			_userListMask.graphics.drawRect(10, _userListControl.y, _userListControl.width, _userListControl.height);
			
			_userCard.x = _userListControl.x + _userListControl.width + 10;
			_userCard.y = _userListControl.y;
			_userCard.width = _width - _userCard.x - 10;
			_userCard.height = _userListControl.height;
			
			_selectorMask.graphics.clear();
			_selectorMask.graphics.beginFill(0x00ff00);
			_selectorMask.graphics.drawRect(10, _userListControl.y + _userListControl.height + 10, _width - 20, bH - _userListControl.height - 30)
			
			_gameSelector.width = _width - 20;
			_gameSelector.height = bH - _userListControl.height - 30;
			_gameSelector.x = 10;
			_gameSelector.y = _userListControl.y + _userListControl.height + 10;
			
			_loadIndicator.x = _userListControl.x + _userListControl.width / 2 - _loadIndicator.width / 2;
			_loadIndicator.y = _userListControl.y + _userListControl.height / 2 - _loadIndicator.height / 2;
			
			_allStarHallView.width = _width;
			_allStarHallView.height = bH;
		}
		
		protected function drawContour(graphics:Graphics):void
		{
			var tabHeight:Number = 30;
			
			graphics.drawRoundRect(0, 0, _width, _height - tabHeight, 14, 14);
		}
		
		protected function loadUserList(localUserId:uint, gameId:uint, limit:uint, timeFrame:uint, userSetId:uint, useNewListControl:Boolean = true):void
		{
			// Disable selection.
			_userListControl.selectionEnabled = false;
			
			// Load top user list using parameters.
			var url:String = ServerFeedUtil.TopUserListUrl(localUserId, gameId, limit, timeFrame, userSetId);
			var request:URLRequest = new URLRequest(url);
			_listLoader = new URLLoader();
			_listLoader.addEventListener(IOErrorEvent.IO_ERROR, onUserListError);
			_listLoader.addEventListener(ProgressEvent.PROGRESS, onUserListProgress);
			_listLoader.addEventListener(Event.COMPLETE, onUserListComplete);
			_listLoader.load(request);
			
			// Show loading indicator.
			_loadIndicator.visible = true;
			
			function onUserListError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onUserListError);
				e.currentTarget.removeEventListener(ProgressEvent.PROGRESS, onUserListProgress);
				e.currentTarget.removeEventListener(Event.COMPLETE, onUserListComplete);
				
				// Apply new data on current list control.
				_userListControl.showError();
				
				// Hide loading indicator.
				_loadIndicator.visible = false;
				
				// Enable selection.
				_userListControl.selectionEnabled = true;
			}
			
			function onUserListProgress(e:ProgressEvent):void
			{
				
			}
			
			function onUserListComplete(e:Event):void
			{
				// Remove event listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onUserListComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onUserListError);
				e.currentTarget.removeEventListener(ProgressEvent.PROGRESS, onUserListProgress);
				
				// Get reference to loaded data.
				var loadedData:String = URLLoader(e.currentTarget).data;
				
				// Parse xml.
				var topUserListXml:XML = new XML(loadedData);
				
				// Show new user list.
				showNewUserList(topUserListXml, getGameName(gameId), useNewListControl);
				
				// Hide loading indicator.
				_loadIndicator.visible = false;
				
				// Enable selection.
				_userListControl.selectionEnabled = true;
			}
		}
		
		protected function showNewUserList(topUserListXml:XML, listName:String = 'Users', newListControl:Boolean = true):void
		{
			// Parse top users.
			var i:uint = 0;
			var topUsers:TopUserCollection = LeaderboardUtil.ParseTopUsers(topUserListXml);
			
			// Parse local user.
			var localUserXml:XMLList = topUserListXml.topUserPointsList.localUser;
			var localUser:TopUser = (localUserXml.children().length() > 0) ? LeaderboardUtil.ParseTopUser(new XML(localUserXml)) : null;
			
			if (newListControl == true)
			{
				// Create new user list control.
				var userListControl:LeaderboardUserListControl = new LeaderboardUserListControl(localUser, topUsers);
				userListControl.listName = listName;
				userListControl.addEventListener(LeaderboardUserListControl.TIME_FRAME_SELECT, onUserListTimeFrameSelect);
				userListControl.addEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
				userListControl.addEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
				userListControl.addEventListener(UserTitleBlockEvent.USER_SELECT, onUserSelect);
				userListControl.init();
				
				// Swap out the old one.
				var oldListControl:LeaderboardUserListControl = _userListControl;
				oldListControl.removeEventListener(LeaderboardUserListControl.TIME_FRAME_SELECT, onUserListTimeFrameSelect);
				oldListControl.removeEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
				oldListControl.removeEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
				oldListControl.removeEventListener(UserTitleBlockEvent.USER_SELECT, onUserSelect);
				_userListControl = userListControl;
				_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animManager.move(oldListControl, oldListControl.x - oldListControl.width, oldListControl.y, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			}
			else
			{
				// Apply new data on current list control.
				_userListControl.setListData(localUser, topUsers, listName);
			}
			
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == oldListControl)
				{
					// Remove event listener.
					_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Remove old list control.
					if (_userListContainer.contains(oldListControl)) _userListContainer.removeChild(oldListControl);
					oldListControl.destroy();
					
					addNewListControl();
				}
			}
			
			function addNewListControl():void
			{
				_userListControl.x = _userListControl.width + 10;
				_userListControl.y = 10;
				_userListContainer.addChild(_userListControl);
				
				_animManager.move(_userListControl, 10, _userListControl.y, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			}
		}
		
		protected function loadGameList(gameTypeId:uint = 0):void
		{
			var url:String = ServerFeedUtil.GameListUrl();
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.load(request);
			
			function onProgress(e:ProgressEvent):void
			{
				
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(Event.COMPLETE, onComplete);
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(Event.COMPLETE, onComplete);
				
				// Parse xml.
				var gameListXml:XML = new XML(loader.data);
				
				// Parse out 3 game lists based on type.
				var games:Array = [];
				var i:uint = 0;
				while (gameListXml.games.game[i] != null)
				{
					var gameXml:XML = gameListXml.games.game[i];
					var gameId:uint = gameXml.gameId;
					var name:String = gameXml.name;
					var type:uint = gameXml.gameTypeId;
					
					var gameTypeArray:Array = games[type] as Array;
					if (gameTypeArray == null) gameTypeArray = [];
					
					gameTypeArray[gameId] = gameXml;
					games[type] = gameTypeArray;
					
					i++;
				}
				
				// Set game list.
				_games = games;
				
				// Sort game lists.
				i = 0;
				var len:uint = _games.length;
				for (i; i < len; i++)
				{
					var gameArray:Array = _games[i] as Array;
					if (gameArray == null) continue;
					
					// Sort games by id.
					//gameArray.sort(gameSort);
				}
				
				// Show game list.
				if (gameTypeId > 0) showGameList(gameTypeId);
				
				function gameSort(a:XML, b:XML):int
				{
					if (a.gameId < b.gameId)
					{
						return 1;
					}
					else if (a.gameId > b.gameId)
					{
						return -1;
					}
					else
					{
						return 0;
					}
				}
			}
		}
		
		protected function showGameList(gameTypeId:uint, useNewSelector:Boolean = false):void
		{
			// MODIFY: Add gameId code 
			
			// Make sure it's not the game list that is already selected.
			if (gameTypeId == _currentGameListId) return;
			_currentGameListId = gameTypeId;
			
			// Load game icons and pass them to the selector.
			var gameList:Array = _games[_currentGameListId] as Array;
			if (gameList == null) return;
			
			// Set flag.
			_useNewUserListFlag = true;
			
			var loadInit:uint = 0;
			var loadCompl:uint = 0;
			var icons:Array = [];
			_currentGameListIds = [];
			var i:uint = 0;
			var len:uint = gameList.length;
			for (i; i < len; i++)
			{
				var gameXml:XML = gameList[i] as XML;
				if (gameXml == null) continue;
				
				var gameId:uint = gameXml.gameId;
				var name:String = gameXml.name;
				
				loadInit++;
				var icon:Sprite = new Sprite();
				var loader:QuickLoader = new QuickLoader(getGameIconUrl(gameId), checkComplete, checkComplete, 1);
				icon.addChild(loader);
				icons.push(icon);
				_currentGameListIds.push(gameId);
			}
			
			function checkComplete():void
			{
				loadCompl++;
				
				// Check if all icons have been loaded.
				if (loadCompl == loadInit)
				{
					finish();
				}
			}
			
			function finish():void
			{
				if (useNewSelector == true)
				{
					// Create new game selector.
					var newSelector:LeaderboardGameSelector = new LeaderboardGameSelector(_width - 20, _height - _tabControl.height - _userListControl.height - 30);
					newSelector.addEventListener(LeaderboardGameSelector.ITEM_SELECT, onGameSelect);
					
					// Swap out the old selector.
					var oldSelector:LeaderboardGameSelector = _gameSelector;
					oldSelector.removeEventListener(LeaderboardGameSelector.ITEM_SELECT, onGameSelect);
					_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
					_animManager.move(oldSelector, oldSelector.x, oldSelector.y + oldSelector.height, 600, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
					
					function onAnimFinish(e:AnimationEvent):void
					{
						if (e.animTarget == oldSelector)
						{
							// Remove event listener.
							_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
							
							// Remove the old selector.
							if (_selectorContainer.contains(oldSelector)) _selectorContainer.removeChild(oldSelector);
							oldSelector.destroy();
							
							// Show the new selector.
							_gameSelector = newSelector;
							_gameSelector.x = oldSelector.x;
							_gameSelector.y = oldSelector.y;
							_selectorContainer.addChild(_gameSelector);
							_animManager.move(_gameSelector, _gameSelector.x, _userListControl.y + _userListControl.height + 10, 600, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
							
							// Pass the icons to the selector.
							_gameSelector.items = icons;
						}
					}
				}
				else
				{
					// Pass the icons to the selector.
					_gameSelector.items = icons;
				}
			}
		}
		
		protected function getGameIconUrl(gameId:uint):String
		{
			return AssetUtil.GetGameAssetUrl(74, 'gameIcon_' + gameId.toString() + '.swf');
		}
		
		protected function getGameName(gameId:uint):String
		{
			for each (var gameTypeList:Array in _games)
			{
				var gameXml:XML = gameTypeList[gameId] as XML;
				if (gameXml == null) continue;
				
				var name:String = gameXml.name;
				return name;
			}
			
			return '';
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onUserListTimeFrameSelect(e:Event):void
		{
			// A new user list time frame has been selected.
			// Load a new top user list.
			loadUserList(_userId, _currentGameId, _listLimit, _userListControl.selectedTimeFrameId, _userListControl.selectedUserSetId, false);
			var uiId:int;
			switch(_userListControl.selectedTimeFrameId){
				case 2:
					uiId=LoggingUtil.LEADER_WEEKLY_TAB;
					break;
				case 3:
					uiId=LoggingUtil.LEADER_MONTHLY_TAB;
					break;
				case 4:
					uiId=LoggingUtil.LEADER_ALL_TIME_TAB;
					break;
			}
			LoggingUtil.sendClickLogging(uiId);
		
		}
		
		private function onUserListUserSetSelect(e:Event):void
		{
			// A new user set has been selected.
			// Load a new top user list.
			loadUserList(_userId, _currentGameId, _listLimit, _userListControl.selectedTimeFrameId, _userListControl.selectedUserSetId, false);
 	   		var uiId:int;
			switch(_userListControl.selectedUserSetId){
				case 1:
					uiId=LoggingUtil.LEADER_FRIENDS_PULLDOWN;
					break;
				case 2:
					uiId=LoggingUtil.LEADER_TEAM_PULLDOWN;
					break;
				case 3:
					uiId=LoggingUtil.LEADER_WORLD_PULLDOWN;
			    	break;
			}
			
			
			LoggingUtil.sendClickLogging(uiId);
			
		}
		
		private function onTurfButtonClick(e:UserTitleBlockEvent):void
		{
			// A turf button was clicked.
			// Send user to someones home turf.
			var roomId:String = 'private_' + e.userId + '_1';
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			
			// Dispatch a close event.
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function onRootTabSelect(e:Event):void
		{
			// A root tab has been selected.
			// Check if it is one of the leaderboard categories.
			var gameTypeId:uint = _GAME_ID_MAP[_tabControl.selectedValue];
			if (gameTypeId > 0)
			{
				_viewSlider.selectViewDirectly(_leaderboardContainer);
				showGameList(gameTypeId, true);
				var uiId:int=LoggingUtil.LEADER_GAMER_TAB;
				if(gameTypeId==4) uiId=LoggingUtil.LEADER_GURU_TAB;
				else if(gameTypeId==5) uiId=LoggingUtil.LEADER_COLLECTOR_TAB;
				LoggingUtil.sendClickLogging(uiId);
				
			}
			else
			{
				_allStarHallView.init();
				_viewSlider.selectViewDirectly(_allStarHallView);
				LoggingUtil.sendClickLogging(LoggingUtil.LEADER_ALLSTAR_HALL_TAB);
			}
		}



		private function onGameSelect(e:Event):void
		{
			// Determine index of clicked game icon.
			var index:uint = _gameSelector.selectedIndex;
			
			// Get reference to game id
			var gameId:uint = _currentGameListIds[index];
			
			LoggingUtil.sendClickLogging(gameIds[gameId]);
			
			_currentGameId = gameId;
			
			// Load top user list.
			loadUserList(_userId, _currentGameId, _listLimit, _userListControl.selectedTimeFrameId, _userListControl.selectedUserSetId, _useNewUserListFlag);
			
			// Set flag.
			_useNewUserListFlag = false;
		}
		
		private function onCloseClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CLOSE));
			LoggingUtil.sendClickLogging(LoggingUtil.LEADER_CLOSE_BUTTON);
			
		}
		
		private function onUserSelect(e:UserTitleBlockEvent):void
		{
			// Load avatar and pass it to the user card.
			// If we are already currently loading a user card,
			// don't begin loading another one but que the last
			// selected user for later loading.
			if (_isLoadingUserCard == true)
			{
				// Don't load this user selection but que it for later.
				_quedSelectedUserId = e.userId;
			}
			else
			{
				// Load the user card.
				loadUserCard(e.userId);
			}
			
			function loadUserCard(userId:uint):void
			{
				// Create a timer.
				// If the card does not load after a certain
				// amount of time, considered it failed.
				var timer:Timer = new Timer(5000);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				timer.start();
				
				_userCard.addEventListener(LeaderboardUserCard.NEW_CARD, onNewCard);
				_isLoadingUserCard = true;
				CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarEvent(userId, _userCard));
				
				function onTimer(e:TimerEvent):void
				{
					// The card failed to load.
					// Kill the timer.
					timer.removeEventListener(TimerEvent.TIMER, onTimer);
					timer.reset();
					timer = null;
					
					// Remove event listeners.
					_userCard.removeEventListener(LeaderboardUserCard.NEW_CARD, onNewCard);
					
					// Set flag.
					_isLoadingUserCard = false;
					
					// If there was a qued selected user,
					// load a card for that user.
					if (_quedSelectedUserId > 0)
					{
						// Load the user card.
						loadUserCard(_quedSelectedUserId);
						_quedSelectedUserId = 0;
					}
				}
				
				function onNewCard(e:Event):void
				{
					// Remove event listeners.
					_userCard.removeEventListener(LeaderboardUserCard.NEW_CARD, onNewCard);
					
					// Kill the timer.
					timer.removeEventListener(TimerEvent.TIMER, onTimer);
					timer.reset();
					timer = null;
					
					// Set flag.
					_isLoadingUserCard = false;
					
					// If there was a qued selected user,
					// load a card for that user.
					if (_quedSelectedUserId > 0)
					{
						// Load the user card.
						loadUserCard(_quedSelectedUserId);
						_quedSelectedUserId = 0;
					}
				}
			}
		}
		
	}
}
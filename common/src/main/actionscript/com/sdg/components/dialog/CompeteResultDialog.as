package com.sdg.components.dialog
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.control.AASModuleLoader;
	import com.sdg.control.BuddyManager;
	import com.sdg.display.LineStyle;
	import com.sdg.events.ChallengesEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.UserTitleBlockEvent;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.leaderboard.list.LeaderboardUserListControl;
	import com.sdg.leaderboard.model.TopUser;
	import com.sdg.leaderboard.model.TopUserCollection;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.store.StoreConstants;
	import com.sdg.util.AssetUtil;
	import com.sdg.util.ServerFeedUtil;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	public class CompeteResultDialog extends Canvas implements ISdgDialog
	{
		// INTERNAL CONSTANTS
		private static var WIDTH:uint = 890;
		private static var HEIGHT:uint = 536;
		private static var X:uint = 19;
		private static var Y:uint = 30;
		private static var RESULTS_LOCATION:Point = new Point(25,15);
		private static var LEADERBOARD_LOCATION:Point = new Point(350,10);
		private static var CLOSE_BUTTONS:Point = new Point(390,500);
		
		// LEADERBOARD CONSTANTS
		private static var FRIENDS_USER_SET_ID:uint = 1;
		private static var WORLD_USER_SET_ID:uint = 3;
		private static var WEEK_TIME_FRAME:uint = 2;
		private static var ALLTIME_TIME_FRAME:uint = 4;
				
		// INPUTS
		//protected var _avatarId:String = "1";
		protected var _gameId:String = "11";
		protected var _gameLogoUrl:String = "/test/static/gameImage?gameId=11";		
		protected var _newRecord:Boolean = false;
		protected var _score:String = "0";
		protected var _tokenReward:String = "0";
		protected var _xpReward:String = "0";

		
		// COMPONENTS
		protected var _bgMask:Sprite;
		protected var _bgOutline:Sprite;
		protected var _background:Sprite;
		protected var _resultsBorder:Sprite;
		protected var _resultsShadedBg:Sprite;
		protected var _playButton:StoreNavBar;
		protected var _worldButton:StoreNavBar;
		protected var _resultHeading1:TextField;
		protected var _resultHeading2:TextField;
		protected var _gameIcon:DisplayObject;
		protected var _scoreBg:DisplayObject;
		protected var _gameScore:TextField;
		protected var _shareButton:StoreNavBar;
		protected var _congratsText:TextField;
		protected var _awardedText:TextField;
		protected var _tokenText:TextField;
		protected var _xpText:TextField;
		protected var _storeMessage:TextField;
		protected var _goldTokensIcon:DisplayObject;
		protected var _xpIcon:DisplayObject;
		protected var _storeIcon:DisplayObject;
		
		// LEADERBOARD VARIABLES
		protected var _userListControl:LeaderboardUserListControl;
		protected var _userListContainer:Sprite;
		protected var _userListMask:Sprite;
		protected var _animManager:AnimationManager;
		protected var _listLoader:URLLoader;
		protected var _listLimit:uint;
		
		protected var _currentGameListId:uint;
		
		protected var _gameNames:Object = new Object();
		protected var _gameNamesRdy:Boolean = false;

		protected var _testData:XML;
		protected var _testString:String;
		protected var _paramString:String = "";
		
		protected var _linkToStoreId:uint = 2209; // default to AAS
		
		protected var _avatar:Avatar = ModelLocator.getInstance().avatar;
		
		public function CompeteResultDialog()
		{
			super();
			
			this.x = X;
			this.y = Y;
			
			this.width = WIDTH;
			this.height = HEIGHT;
		}
		
		public function init(params:Object):void
		{
			if (params)
			{
				var achievementData:XML = params.xml as XML;

				_score = String(achievementData.finalScore);
				_gameId = String(achievementData.gameId);
				_gameLogoUrl = String(achievementData.gameLogo);
				_tokenReward = String(achievementData.tokensEarned);
				_xpReward = String(achievementData.experienceEarned);
				
				var intGameId:int = 0;
				try {intGameId = parseInt(_gameId);}
				catch (e:Error) {return;}
				_linkToStoreId = StoreConstants.getStoreFromGameId(intGameId);
				
				if (achievementData.isNewHighScore == 1)
				{
					_newRecord = true;
				}
				else
				{
					_newRecord = false;
				}
			}
			
			// Load Game Name Mapping
			loadGameList();
			
			var url:String = AssetUtil.GetGameAssetUrl(74, 'background.swf');
			_background = new QuickLoader(url, showDialog, null, 3);
		}
			
			
		protected function showDialog():void
		{
			showResults();
			
			showLeaderboard();
		}
		
		public function showResults():void
		{
			// Set Background Size
			_background.width = width;
			_background.height = height;
			
			// Add Mask
			//_bgMask = new Sprite();
			//_bgMask.graphics.beginFill(0x00ff00);
			//_bgMask.graphics.drawRoundRect(0, 0, width, height, 14, 14);
			//_background.mask = _bgMask;
			
			this.rawChildren.addChild(_background);
			
			_bgOutline = new Sprite();
			_bgOutline.graphics.clear();
			_bgOutline.graphics.lineStyle(3, 0x000000);
			_bgOutline.graphics.drawRoundRect(0, 0, width, height, 14, 14);
			this.rawChildren.addChild(_bgOutline);
			
			_resultsShadedBg = new Sprite();
			_resultsShadedBg.graphics.beginFill(0x000000,.6);
			_resultsShadedBg.graphics.drawRect(0,0,323,503);
			this.rawChildren.addChild(_resultsShadedBg);
			_resultsShadedBg.x = RESULTS_LOCATION.x+1;
			_resultsShadedBg.y = RESULTS_LOCATION.y+1;

			_resultsBorder = new Sprite();
			_resultsBorder.graphics.lineStyle(6,0xffffff);
			//_resultsBorder.graphics.beginFill(0xffffff,1);
			_resultsBorder.graphics.drawRect(0,0,325,506);
			//var borderMask:Sprite = new Sprite();
			//borderMask.x = RESULTS_LOCATION.x+6;
			//borderMask.y = RESULTS_LOCATION.x+6;
			//borderMask.graphics.beginFill(0x00ff00);
			//borderMask.graphics.drawRect(0,0,320,501);
			//this.rawChildren.addChild(borderMask);
			//_resultsBorder.mask = borderMask;
			this.rawChildren.addChild(_resultsBorder);
			_resultsBorder.x = RESULTS_LOCATION.x;
			_resultsBorder.y = RESULTS_LOCATION.y;
			
			// Place Buttons
			buildButton(CLOSE_BUTTONS.x,CLOSE_BUTTONS.y,170,"PLAY AGAIN","PLAY AGAIN","onPlayAgainClick");
			buildButton(CLOSE_BUTTONS.x+200,CLOSE_BUTTONS.y,210,"BACK TO WORLD","BACK TO WORLD","onWorldClick");
			
			_resultHeading1 = new TextField();
			this.rawChildren.addChild(_resultHeading1);
			_resultHeading1.embedFonts = true;
			_resultHeading1.defaultTextFormat = new TextFormat('EuroStyle', 35, 0xffffff, true);
			_resultHeading1.autoSize = TextFieldAutoSize.LEFT;
			_resultHeading1.selectable = false;
			if (_newRecord == false)
			{
				_resultHeading1.x = RESULTS_LOCATION.x+35;
				_resultHeading1.text = "FINAL SCORE";
			}
			else
			{
				_resultHeading1.x = RESULTS_LOCATION.x+6;  // TBD - Check on this number
				_resultHeading1.text = "NEW PERSONAL";
			}
			_resultHeading1.y = RESULTS_LOCATION.y+10;
			_resultHeading1.filters = [new GlowFilter(0x3cc6db, .6, 6, 6, 4)];
			
			_resultHeading2 = new TextField();
			if (_newRecord == true)
				this.rawChildren.addChild(_resultHeading2);
			_resultHeading2.embedFonts = true;
			_resultHeading2.defaultTextFormat = new TextFormat('EuroStyle', 35, 0xffffff, true);
			_resultHeading2.autoSize = TextFieldAutoSize.LEFT;
			_resultHeading2.selectable = false;
			_resultHeading2.text = "HIGH SCORE";
			_resultHeading2.x = RESULTS_LOCATION.x+44;
			_resultHeading2.y = RESULTS_LOCATION.y+50;
			_resultHeading2.filters = [new GlowFilter(0x3cc6db, .6, 6, 6, 4)];
			
			_gameIcon = new QuickLoader(Environment.getAssetUrl()+_gameLogoUrl, onGameIconLoadComplete,null,3);
			
			if (_newRecord)
			{
				_scoreBg = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/FinalScore_box_withStars.swf', onScoreStarsBgLoadComplete,null,3);
			}
			else
			{
				_scoreBg = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/FinalScore_box.swf', onScoreBgLoadComplete,null,3);
			}

			_gameScore = new TextField();
			this.rawChildren.addChild(_gameScore);
			_gameScore.embedFonts = true;
			_gameScore.defaultTextFormat = new TextFormat('EuroStyle', 35, 0xf1d000, true);
			_gameScore.autoSize = TextFieldAutoSize.CENTER;
			_gameScore.selectable = false;
			_gameScore.x = RESULTS_LOCATION.x+160;
			_gameScore.y = RESULTS_LOCATION.y+172;
			_gameScore.text = _score;
			_gameScore.filters = [new GlowFilter(0x111111, .6, 6, 6, 4)];
			
			buildButton(RESULTS_LOCATION.x+80,RESULTS_LOCATION.y+230,170,"SHARE SCORE","SCORES SENT","onShareScoreClick");
			
			_congratsText = new TextField();
			this.rawChildren.addChild(_congratsText);
			_congratsText.embedFonts = true;
			_congratsText.defaultTextFormat = new TextFormat('EuroStyle', 26, 0xffffff, true);
			_congratsText.autoSize = TextFieldAutoSize.LEFT;
			_congratsText.selectable = false;
			_congratsText.text = "Congratulations!";
			_congratsText.x = RESULTS_LOCATION.x+61;
			_congratsText.y = RESULTS_LOCATION.y+268;
			
			_awardedText = new TextField();
			this.rawChildren.addChild(_awardedText);
			_awardedText.embedFonts = true;
			_awardedText.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true);
			_awardedText.autoSize = TextFieldAutoSize.LEFT;
			_awardedText.selectable = false;
			_awardedText.text = "You've been awarded: ";
			_awardedText.x = RESULTS_LOCATION.x+85;
			_awardedText.y = RESULTS_LOCATION.y+308;
			
			//_goldTokensIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/icon_3Tokens_payout.swf', onTokensIconLoadComplete,null,3);
			
			_tokenText = new TextField();
			this.rawChildren.addChild(_tokenText);
			_tokenText.embedFonts = true;
			//_tokenText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xf1d000, true);
			_tokenText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			_tokenText.autoSize = TextFieldAutoSize.LEFT;
			_tokenText.selectable = false;
			_tokenText.text = "+ "+_tokenReward+" Tokens";
			_tokenText.x = RESULTS_LOCATION.x+61;
			_tokenText.y = RESULTS_LOCATION.y+335;
			_tokenText.filters = [new GlowFilter(0xffcc33, 1, 6, 6, 1)];
			
			//_xpIcon = new QuickLoader(Environment.getAssetUrl()+'/test/gameSwf/gameId/99/gameFile/icon_XP_payout.swf', onXPIconLoadComplete,null,3);

			_xpText = new TextField();
			this.rawChildren.addChild(_xpText);
			_xpText.embedFonts = true;
			//_xpText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xf1d000, true);
			_xpText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true);
			_xpText.autoSize = TextFieldAutoSize.LEFT;
			_xpText.selectable = false;
			_xpText.text = "+ "+_xpReward+" Points";
			_xpText.x = RESULTS_LOCATION.x+61;
			_xpText.y = RESULTS_LOCATION.y+377;
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
			_storeMessage.defaultTextFormat = new TextFormat('EuroStyle', 11, 0xffffff, true);
			//_storeMessage.autoSize = TextFieldAutoSize.LEFT;
			_storeMessage.selectable = false;
			_storeMessage.multiline = true;
			_storeMessage.wordWrap = true;
			_storeMessage.text = "Visit one of the official shops to collect the latest gear.";
			_storeMessage.x = RESULTS_LOCATION.x+177;
			_storeMessage.y = RESULTS_LOCATION.y+436;
			_storeMessage.width = 150;
		}
		
		private function onGameIconLoadComplete():void
		{
			this.rawChildren.addChild(_gameIcon);
			_gameIcon.x = RESULTS_LOCATION.x+95;
			_gameIcon.y = RESULTS_LOCATION.y+85;
			_gameIcon.scaleX = .6;
			_gameIcon.scaleY = .6;
		}
		
		private function onScoreStarsBgLoadComplete():void
		{
			this.rawChildren.addChild(_scoreBg);
			_scoreBg.x = RESULTS_LOCATION.x+5;
			_scoreBg.y = RESULTS_LOCATION.y+170;
			this.rawChildren.removeChild(_gameScore);
			this.rawChildren.addChild(_gameScore);
		}
		
		private function onScoreBgLoadComplete():void
		{
			this.rawChildren.addChild(_scoreBg);
			_scoreBg.x = RESULTS_LOCATION.x+5;
			_scoreBg.y = RESULTS_LOCATION.y+170;
			this.rawChildren.removeChild(_gameScore);
			this.rawChildren.addChild(_gameScore);
		}
		
		private function onTokensIconLoadComplete():void
		{
			this.rawChildren.addChild(_goldTokensIcon);
			_goldTokensIcon.x = RESULTS_LOCATION.x+70;
			_goldTokensIcon.y = RESULTS_LOCATION.y+340;
		}
		
		private function onXPIconLoadComplete():void
		{
			this.rawChildren.addChild(_xpIcon);
			_xpIcon.x = RESULTS_LOCATION.x+70;
			_xpIcon.y = RESULTS_LOCATION.y+330+70;
		}
		
		private function onStoreIconLoadComplete():void
		{
			this.rawChildren.addChild(_storeIcon);
			_storeIcon.x = RESULTS_LOCATION.x+12;
			_storeIcon.y = RESULTS_LOCATION.y+435;
			_storeIcon.scaleX = 1;
			_storeIcon.scaleY = 1;
			_storeIcon.addEventListener(MouseEvent.CLICK,onStoreClick);
		}
		
		///////////////////////////////////
		// LEADERBOARD 
		///////////////////////////////////
		
		public function showLeaderboard():void
		{
			// CREATE LEADERBOARD OBJECT
			this.initializeLeaderboard();
			
			//LOAD INITIAL DATA
			this.loadLeaderboardData(WEEK_TIME_FRAME,FRIENDS_USER_SET_ID,true);
		}
		
		private function initializeLeaderboard():void
		{
			_userListControl = new LeaderboardUserListControl();
			_userListControl.addEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
			_userListControl.x = 10;
			_userListControl.y = 10;
			
			_userListControl.setUserSetVisibility(true);
			
			_userListMask = new Sprite();
			_userListContainer = new Sprite();
			_animManager = new AnimationManager();
			_listLimit = 40;
			
			_userListContainer.x = LEADERBOARD_LOCATION.x;
			_userListContainer.y = LEADERBOARD_LOCATION.y;
			
			_userListContainer.mask = _userListMask;
			this.rawChildren.addChild(_userListContainer);
			this.rawChildren.addChild(_userListMask);
			_userListContainer.addChild(_userListControl);
			
			_userListMask.graphics.clear();
			_userListMask.graphics.beginFill(0x00ff00);
			_userListMask.graphics.drawRect(LEADERBOARD_LOCATION.x+10, LEADERBOARD_LOCATION.y+10, _userListControl.width, _userListControl.height);
		}
		
		private function loadLeaderboardData(timeFrame:uint,userSetId:uint,useNewListControl:Boolean):void
		{
			// Disable selection.
			_userListControl.selectionEnabled = false;
			
			// Load top user list using parameters.
			var url:String = ServerFeedUtil.TopUserListUrl(_avatar.id, parseInt(_gameId), _listLimit, timeFrame, userSetId);
			//trace("++++++++++++++++++++++++ENTRY DATA: "+_avatar.id+" "+_gameId+" "+_listLimit+" "+timeFrame+" "+userSetId);
			var request:URLRequest = new URLRequest(url);
			_listLoader = new URLLoader();
			_listLoader.addEventListener(IOErrorEvent.IO_ERROR, onUserListError);
			_listLoader.addEventListener(Event.COMPLETE, onUserListComplete);
			_listLoader.load(request);
			
			// Show loading indicator.
			//_loadIndicator.visible = true;
			
			function onUserListError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onUserListError);
				e.currentTarget.removeEventListener(Event.COMPLETE, onUserListComplete);
				
				// Apply new data on current list control.
				_userListControl.showError();
				
				// Hide loading indicator.
				//_loadIndicator.visible = false;
				
				// Enable selection.
				_userListControl.selectionEnabled = true;
			}
			
			function onUserListComplete(e:Event):void
			{
				// Remove event listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onUserListComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onUserListError);
				
				// Get reference to loaded data.
				var loadedData:String = URLLoader(e.currentTarget).data;
				
				// Parse xml.
				var topUserListXml:XML = new XML(loadedData);
				
				// Show new user list.
				showNewUserList(topUserListXml, getGameName(parseInt(_gameId)), useNewListControl);
				
				// Hide loading indicator.
				//_loadIndicator.visible = false;
				
				// Enable selection.
				_userListControl.selectionEnabled = true;
			}
		}
		
		protected function showNewUserList(topUserListXml:XML, listName:String = 'Users', newListControl:Boolean = false):void
		{
			// Parse top users.
			var i:uint = 0;
			var usersXml:XMLList = topUserListXml.topUserPointsList.users;
			var topUsers:TopUserCollection = (usersXml.children().length() > 0) ? parseTopUsers(usersXml) : new TopUserCollection();
			
			// Parse local user.
			var localUserXml:XMLList = topUserListXml.topUserPointsList.localUser;
			var localUser:TopUser = (localUserXml.children().length() > 0) ? parseTopUser(new XML(localUserXml)) : null;
			
			if (newListControl == true)
			{
				// Create new user list control.
				var userListControl:LeaderboardUserListControl = new LeaderboardUserListControl(localUser, topUsers);
				userListControl.listName = listName;
				userListControl.addEventListener(LeaderboardUserListControl.TIME_FRAME_SELECT, onUserListTimeFrameSelect);
				userListControl.addEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
				userListControl.addEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
				//userListControl.addEventListener(UserTitleBlockEvent.USER_SELECT, onUserSelect);
				userListControl.init();
				userListControl.setUserSetVisibility(true);
				
				// Swap out the old one.
				var oldListControl:LeaderboardUserListControl = _userListControl;
				oldListControl.removeEventListener(LeaderboardUserListControl.TIME_FRAME_SELECT, onUserListTimeFrameSelect);
				oldListControl.removeEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
				oldListControl.removeEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
				//oldListControl.removeEventListener(UserTitleBlockEvent.USER_SELECT, onUserSelect);
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
		
		protected function loadGameList():void
		{
			var url:String = ServerFeedUtil.GameListUrl();
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(Event.COMPLETE, onComplete);
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(Event.COMPLETE, onComplete);
				
				// Parse xml.
				var gameListXml:XML = new XML(loader.data);
				
				// Create Game Name Mapping
				var i:uint = 0;
				while (gameListXml.games.game[i] != null)
				{
					var gameXml:XML = gameListXml.games.game[i];
					var id:uint = gameXml.gameId;
					var name:String = gameXml.name;
					_gameNames[id] = name;					

					i++;
				}
				
				_gameNamesRdy = true;
			}
		}
		
		
		// INDEPENDENT LISTENERS
		private function onUserListUserSetSelect(e:Event):void
		{
			//// A new user set has been selected.
			//// Load a new top user list.
			//loadLeaderboardData(_userListControl.selectedTimeFrameId, WORLD_USER_SET_ID,true);
			loadLeaderboardData(_userListControl.selectedTimeFrameId, _userListControl.selectedUserSetId,false);
		}
		
		private function onUserListTimeFrameSelect(e:Event):void
		{
			// A new user list time frame has been selected.
			// Load a new top user list.
			//loadLeaderboardData(_userListControl.selectedTimeFrameId, WORLD_USER_SET_ID,false);
			loadLeaderboardData(_userListControl.selectedTimeFrameId, _userListControl.selectedUserSetId,false);
		}
		
		private function onTurfButtonClick(e:UserTitleBlockEvent):void
		{
			// Turf Button Clicked - send user to that home turf
			var roomId:String = 'private_' + e.userId + '_1';
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			
			// close this dialog
			this.close();
		}
		
		private function onStoreClick(e:MouseEvent):void
		{
			var params:Object = new Object();
			
			params.storeId = _linkToStoreId;

			AASModuleLoader.openStoreModule(params);
			this.close();
		}
		
		// LEADERBOARD UTILITIES
		protected function parseTopUsers(userList:XMLList):TopUserCollection
		{
			var i:uint = 0;
			var topUsers:TopUserCollection = new TopUserCollection();
			while (userList.u[i] != null)
			{
				var user:XML = userList.u[i];
				var topUser:TopUser = parseTopUser(user);
				topUsers.push(topUser);
				
				i++;
			}
			
			return topUsers;
		}
		
		protected function parseTopUser(user:XML):TopUser
		{
			var id:uint = (user.@id != null) ? user.@id : 0;
			var place:uint = (user.@place != null) ? user.@place : int.MAX_VALUE;
			var name:String = (user.n != null) ? user.n : '';
			var points:int = (user.pts != null) ? user.pts : 0;
			var level:uint = (user.l > 0) ? user.l : 1;
			var teamId:uint = (user.team.@id != null) ? user.team.@id : 1;
			var teamName:String = 'Team Name';
			var color1:uint = parseInt('0x' + user.team.c[0]);
			var color2:uint = parseInt('0x' + user.team.c[1]);
			
			var topUser:TopUser = new TopUser(id, name, place, level, points, teamId, teamName, color1, color2);
			
			return topUser;
		}
		
		protected function getGameIconUrl(gameId:uint):String
		{
			return AssetUtil.GetGameAssetUrl(74, 'gameIcon_' + gameId.toString() + '.swf');
		}
		
		protected function getGameName(gameId:uint):String
		{
			if (_gameNamesRdy)
				if (_gameNames[gameId])
					return String(_gameNames[gameId]);
			
			return "ERROR";
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
			else if (callable == "onShareScoreClick")
			{
				button.addEventListener(MouseEvent.CLICK, onShareScoreClick);
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
			
			function onShareScoreClick(event:MouseEvent):void
			{
				// Remove Listeners
				button.removeEventListener(MouseEvent.CLICK, onShareScoreClick);
				button.removeEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
				button.removeEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
				
				var result:Boolean = shareScore();
				
				if (result == false)
				{
					button.addEventListener(MouseEvent.CLICK, onShareScoreClick);
					button.addEventListener(MouseEvent.MOUSE_OVER,onButtonMouseOver);
					button.addEventListener(MouseEvent.MOUSE_OUT,onButtonMouseOut);
					return;
				}
				
				// Change Text
				button.label = onClickText;
				
				// Set New Appearance
				setMouseOverButton(event.currentTarget);
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
		// SHARE SCORE
		/////////////////////////////////////
		protected function shareScore():Boolean
		{
			// How Many Buddies do I tell?
			BuddyManager.start();
			var buddyCount:int = BuddyManager.buddyCount;
			
			// if no buddies, no message
			if (buddyCount == 0)
				return false;
			
			// Send score to all buddies
			if (getGameName(parseInt(_gameId)) != "ERROR")
			{
				var valuesAmalgom:String = "8;"+_avatar.name+";"+_score+";"+getGameName(parseInt(_gameId));
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "shareWithFriends", { shareWithFriends:valuesAmalgom });
				notifyMessageSent(buddyCount);
				return true;
			}
			else
			{
				return false;	
			}
		}
		
		protected function notifyMessageSent(buddyCount:uint):void
		{
			// Tell Player Buddies Are Informed
			if (buddyCount > 1)
			{
				MainUtil.showDialog(ResultNotifyBuddiesDialog, {title:"MESSAGES SENT:"}, false, false);
			}
			else if (buddyCount == 1)
			{
				MainUtil.showDialog(ResultNotifyBuddiesDialog, {title:"MESSAGE SENT:"}, false, false);
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
			this.close();
		}
		
		public function close():void
		{
			// Remove Listeners
			_storeIcon.removeEventListener(MouseEvent.CLICK,onStoreClick);
			//_userListControl.addEventListener(LeaderboardUserListControl.USER_SET_SELECT, onUserListUserSetSelect);
			//userListControl.addEventListener(LeaderboardUserListControl.TIME_FRAME_SELECT, onUserListTimeFrameSelect);
			//userListControl.addEventListener(UserTitleBlockEvent.TURF_BUTTON_CLICK, onTurfButtonClick);
				
			PopUpManager.removePopUp(this);
		}
		
	}
}
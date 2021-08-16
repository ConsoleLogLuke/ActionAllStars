package com.sdg.control.room.itemClasses
{
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.controls.MVPAlert;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.CardKiosk;
	import com.sdg.components.dialog.CardTradingLobby;
	import com.sdg.components.dialog.InWorldShopDialog;
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.dialog.SinglePlayerMissionDialog;
	import com.sdg.control.AASModuleLoader;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.GameLauncherEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.game.GameMenuDialog;
	import com.sdg.game.counter.GamePlayCounter;
	import com.sdg.game.views.GameQueuePlayerList;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarAchievement;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.RoomLayerType;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.quest.QuestManager;
	import com.sdg.sim.map.TileMap;
	import com.sdg.sim.map.TileSet;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.IRoomView;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.events.CloseEvent;
	
	public class GameLauncher extends RoomItemController
	{
		public static const TRADING_CARD_LOBBY_ID:uint = 19;
		public static const TRADING_CARD_KIOSK_ID:uint = 20;
		
		private var _gameId:int;
		private var _practiceGameId:int;
		private var _isPractice:Boolean;
		
		public function GameLauncher()
		{
		}
		
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			super.mouseClickHandler(event);
			
			// Make sure we are not entering a room.
			if (RoomManager.isEnteringRoom) return;
			
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			var membershipStatus:int = userAvatar.membershipStatus;
			var gameId:uint = item.attributes.gameId;
			_practiceGameId = item.attributes.practiceGameId;
			_gameId = gameId;
			var useNoChallengeScreens:Boolean = item.attributes.noChallengeScreen;
			
			// Dispatch an event that signifies a game launch point was clicked.
			var gameLaunchEvent:GameLauncherEvent = new GameLauncherEvent(GameLauncherEvent.CLICKED);
			gameLaunchEvent.gameId = gameId;
			dispatchEvent(gameLaunchEvent);
			
			switch (gameId)
			{
				case TRADING_CARD_LOBBY_ID:
					MainUtil.showDialog(CardTradingLobby);
					break;
					
				case TRADING_CARD_KIOSK_ID:
					// If playing as a guest.
					if (ModelLocator.getInstance().avatar.membershipStatus == Constants.MEMBER_STATUS_GUEST)
						//MainUtil.showDialog(MonthFreeUpsellDialog, {showPremiumHeader:false, messaging:"This feature is only available if you register."});
						MainUtil.showDialog(SaveYourGameDialog);
					else
						MainUtil.showDialog(CardKiosk);
					break;
				
				case Constants.RBI_GAME_ID:
					if (membershipStatus == Constants.MEMBER_STATUS_GUEST)
						MainUtil.showDialog(SaveYourGameDialog);
					else if (membershipStatus == Constants.MEMBER_STATUS_FREE)
					{
//						CairngormEventDispatcher.getInstance().addEventListener(GetStatsEvent.STATS_RECEIVED, onStatsReceived);
//						CairngormEventDispatcher.getInstance().addEventListener(GetStatsEvent.GET_STATS_ERROR, onStatsError);
//						CairngormEventDispatcher.getInstance().dispatchEvent(new GetStatsEvent(GetStatsEvent.GET_STATS, gameId, null, true));
						
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_RBI);
						
						var alert:MVPAlert = MVPAlert.show("This game is for MVP Members only. Become part of the MVP team now " + 
								"to unlock all the awesome sports and arcade games in Action AllStars!", "Join the Team!", onClose);
						
						alert.addButton("Become A Member", LoggingUtil.MVP_UPSELL_CLICK_RBI, 250);
					}
					else
						AASModuleLoader.openGameModule(gameId);
					
					break;
				case Constants.NBA_ALLSTARS_GAME_ID:
					if (membershipStatus == Constants.MEMBER_STATUS_GUEST)
						MainUtil.showDialog(SaveYourGameDialog);
					else if (membershipStatus == Constants.MEMBER_STATUS_FREE)
					{
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_NBA_ALLSTARS);
						
						CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/" + gameId + "/gameFile/mvp_upsell.swf",
							LoggingUtil.MVP_UPSELL_CLICK_NBA_ALLSTARS, onClose);
					}
					else
						MainUtil.showDialog(GameMenuDialog);
					
					break;
				case Constants.TOP_SHOT_GAME_ID:
					var mission:AvatarAchievement = QuestManager.getActiveQuest(QuestManager.CATCH_A_THIEF_QUEST_ID);
					if (mission == null)
						MainUtil.showDialog(InWorldShopDialog, Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=" + 4);
						//SdgAlertChrome.show("You must be on the Catch A Thief mission to enter.", "Time Out!");
					else
						RoomManager.getInstance().loadGame(gameId);
					break;
				case Constants.SINGLEPLAYER_MISSION1_GAME_ID:
					if (membershipStatus == Constants.MEMBER_STATUS_GUEST)
					{
						MainUtil.showDialog(SaveYourGameDialog);
					}
					else
					{
						MainUtil.showDialog(SinglePlayerMissionDialog,{gameID:gameId});
					}
					break;
				case Constants.ZOMBIE_BOSS_GAME_ID:
					// If they've already beaten the game launch them into the next room.
					// Otherwise have them play the game.
					var zombieMission:AvatarAchievement = QuestManager.getActiveQuest(QuestManager.ZOMBIE_BOSS_QUEST_ID);
					// this mission should never be null, but just in case
					if (zombieMission == null || zombieMission.isComplete == false)
					{
						if(membershipStatus == Constants.MEMBER_STATUS_PREMIUM)
						{
							RoomManager.getInstance().loadGame(gameId);
						}
						else
						{
							// get the new logging IDs
							LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_ZOMBIE_BOSSFIGHT);
							CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/" + gameId + "/gameFile/mvp_upsell.swf",
											LoggingUtil.MVP_UPSELL_CLICK_ZOMBIE_BOSSFIGHT, onClose);
						}
					}
					else
					{
						RoomManager.getInstance().enterRoom(Constants.ROOM_ID_BULLPEN);
					}
					break;
				case Constants.ROCK_JENGA_GAME_ID:
					if(membershipStatus == Constants.MEMBER_STATUS_PREMIUM)
					{
						trace("Loading without Challenge Screen");
						RoomManager.getInstance().loadGame(gameId);
					}
					// This shouldn't ever happen since they need to do the scuba mission first
					// but just in case something else happens.
					else if(membershipStatus == Constants.MEMBER_STATUS_GUEST)
					{
						MainUtil.showDialog(SaveYourGameDialog);
					}
					// Free memeber upsell
					else
					{
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_ROCK_AVALANCHE);
						
						var alertRockJenga:MVPAlert = MVPAlert.show("Become an MVP Member to help rescue Jermaine O'Neal. We" + 
								" need your help!", "Join the Team!", onClose);
						alertRockJenga.addButton("Become A Member", LoggingUtil.MVP_UPSELL_CLICK_ROCK_AVALANCHE, 250);
					}
					
					break;
					
				case Constants.KICKER_TRY_OUT_GAME_ID:
					
					// CHECK REGISTRATION STATUS
					if (membershipStatus == Constants.MEMBER_STATUS_GUEST)
					{
						MainUtil.showDialog(SaveYourGameDialog);
						break;
					}
					
					// CHECK MVP STATUS
					if(membershipStatus != Constants.MEMBER_STATUS_PREMIUM)
					{
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_KICKER_TRY_OUT);
						/*
						var alertKickerTryOut:MVPAlert = MVPAlert.show("Become an MVP Member to try out as their kicker. They" + 
							" need your help!", "Join the Team!", onClose);
						alertKickerTryOut.addButton("Become A Member", LoggingUtil.MVP_UPSELL_CLICK_KICKER_TRY_OUT, 250);
						*/
						
						CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/" + gameId + "/gameFile/mvp_upsell.swf",
											LoggingUtil.MVP_UPSELL_CLICK_KICKER_TRY_OUT, onClose);
						
						break;
					}

					// CHECK ACHIEVEMENT STATUS
					var turkeyMission:AvatarAchievement = QuestManager.getActiveQuest(QuestManager.KICKER_TRY_OUT_QUEST_ID);
					//if (turkeyMission != null && turkeyMission.isComplete == false)
					if (turkeyMission != null)
					{
						RoomManager.getInstance().loadGame(gameId);
					}
					else
					{
						MainUtil.showDialog(InteractiveDialog, {url:Environment.getAssetUrl() + "/test/gameSwf/gameId/64/gameFile/find_turkeys_first.swf",id:"Find Turkeys First!"},false,false);
					}

					break;
				
				case 67:
					// This is hard coded for the skateboard game.
					// This must be mroe generalized before luanch.
					// It should work with any standard multy player game.
					showGameLaunchScreen(gameId, true);
					break;	
				default:
					// Show the game launch screen.
					showGameLaunchScreen(gameId);
			}
			
			function onClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;
				
				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_RBI || 
					identifier == LoggingUtil.MVP_UPSELL_CLICK_NBA_ALLSTARS ||
					identifier == LoggingUtil.MVP_UPSELL_CLICK_ROCK_AVALANCHE ||
					identifier == LoggingUtil.MVP_UPSELL_CLICK_ZOMBIE_BOSSFIGHT ||
					identifier == LoggingUtil.MVP_UPSELL_CLICK_KICKER_TRY_OUT)
					MainUtil.goToMVP(identifier);
			}
			
		}
		
		override protected function initializeDisplay():void
		{
			super.initializeDisplay();
		}
		
		private function showGameLaunchScreen(gameId:int, isMultiplayer:Boolean = false):void
		{
			// Load and show the game launch screen.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			var waitingForPlayersPopUp:Sprite;
			var waitingForPlayersAlert:GameQueuePlayerList;
			var queueTimer:Timer;
			var timeUntilQueueLaunch:int;
			var maxQueueWait:int;
			var queueLaunchTime:int;
			var mpGameRoomEntered:Boolean;
			var gameLaunchScreen:DisplayObject;
			var gameImageLoader:QuickLoader;
			var gameImage:DisplayObject;
			var launchScreenContainer:Sprite;
			var progressAlert:ProgressAlertChrome;
			var roomView:IRoomView = context.roomView;
			var practiceGamePlayCount:int;
			var practiceGamePlayCountLoaded:Boolean;
			var url:String = AssetUtil.GetGameAssetUrl(99, 'game_launch.swf');
			progressAlert = ProgressAlertChrome.show('Launching Game.', 'Launching Game');
			var gameLaunchLoader:QuickLoader = new QuickLoader(url, onGameLaunchScreenComplete, onGameLaunchScreenFail);
			
			// If this game has a practice mode avaialable, load the all time play count for the practice mode.
			// We make sure they have done practice mode atleast once before we let them play normal mode.
			if (_practiceGameId)
			{
				GamePlayCounter.loadAllTimeGamePlayCount(_practiceGameId, onAllTimePracticePlaysLoaded);
			}
			
			function onGameLaunchScreenFail():void
			{
				// Hide progress alert.
				progressAlert.close(0);
				
				// Just attempt to launch the game without a launch screen.
				RoomManager.getInstance().loadGame(gameId, 0, 0, 0, 0, true);
			}
			
			function onGameImageFail():void
			{
				// Show the launch screen without a game image.
				showLaunchScreen();
			}
			
			function onGameLaunchScreenComplete():void
			{
				// Game launch screen has loaded.
				// Now load the game image.
				gameLaunchScreen = gameLaunchLoader.content;
				// If there is a practice game id, set launch screen to allow practice selection.
				if (_practiceGameId) Object(gameLaunchScreen).allowPractice = true;
				var gameImageUrl:String = AssetUtil.GetGameAssetUrl(gameId, 'title_image.swf');
				gameImageLoader = new QuickLoader(gameImageUrl, onGameImageComplete, onGameImageFail);
			}
			
			function onGameImageComplete():void
			{
				// The game image has loaded.
				// Now pass the image into the game launch screen and show it.
				gameImage = gameImageLoader.content;
				var gameLaunchScreenObj:Object = gameLaunchScreen;
				if (gameLaunchScreenObj['setImage']) gameLaunchScreenObj.setImage(gameImage);
				
				// If the practice play count has been loaded,
				// allow or disallow normal play based on practice play count.
				if (practiceGamePlayCountLoaded)
				{
					if (Object(gameLaunchScreen)['allowPlay'] != null) Object(gameLaunchScreen).allowPlay = (practiceGamePlayCount > 0);
				}
				
				showLaunchScreen();
			}
			
			function onPlayClick():void
			{
				if (!item) return;
				
				// Remove the game launch screen.
				removeLaunchScreen();
				
				// Make sure the user is registered.
				if (userAvatar.membershipStatus == MembershipStatus.GUEST)
				{
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}
				
				// If single player, just launch the game.
				if (!isMultiplayer)
				{
					RoomManager.getInstance().loadGame(gameId, 0, 0, 0, 0, true);
				}
				else
				{
					// Make sure user has not hit their game limit.
					if (RoomManager.getInstance().isUserAtGamePlayLimit(userAvatar.membershipStatus, _gameId))
					{
						RoomManager.getInstance().handleUserAtGameLimit();
						return;
					}
					
					// If multiplayer, join game que.
					// Pass avatar id, game id, launch point id.
					SocketClient.addPluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_SUCCESS, onJoinGameQueueSuccess);
					SocketClient.addPluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_FAIL, onJoinGameQueueFail);
					SocketClient.addPluginActionHandler(SocketEvent.LEAVE_GAME_QUEUE_SUCCESS, onLeaveGameQueueSuccess);
					SocketClient.addPluginActionHandler(SocketEvent.LAUNCH_GAME_QUEUE, onLaunchGameQueue);
					SocketClient.getInstance().sendPluginMessage('avatar_handler', 'mpJoinGameQueue', {avatarId: userAvatar.avatarId, gameId: gameId, launchPointId: item.id});
					
					// Try to walk to open game queue tile.
					var floorTileMap:TileMap = context.room.getMapLayer(RoomLayerType.FLOOR);
					var gameQueTileCoordinate:Point = floorTileMap.getOpenTileCoordinate('gamequeue_' + _gameId);
					if (!gameQueTileCoordinate) gameQueTileCoordinate = floorTileMap.getFirstTileCoordinate('gamequeue_' + _gameId);
					if (gameQueTileCoordinate) RoomManager.getInstance().userController.walk(gameQueTileCoordinate.x, gameQueTileCoordinate.y);
				}
			}
			
			function onPracticeClick():void
			{
				// Check for practice game id.
				if (!_practiceGameId) return;
				
				// If multiplayer, launch game in practice mode.
				// Pass avatar id, game id, launch point id.
				_isPractice = true;
				SocketClient.addPluginActionHandler(SocketEvent.LAUNCH_GAME_QUEUE, onLaunchGameQueue);
				SocketClient.getInstance().sendPluginMessage('avatar_handler', 'mpJoinGamePracticeQueue', {avatarId: userAvatar.avatarId, gameId: _practiceGameId, launchPointId: item.id});
				
				// Remove launch screen.
				removeLaunchScreen();
			}
			
			function onBackClick():void
			{
				// Remove the game launch screen.
				removeLaunchScreen();
			}
			
			function showLaunchScreen():void
			{
				launchScreenContainer = new Sprite();
				launchScreenContainer.graphics.beginFill(0, 0.8);
				launchScreenContainer.graphics.drawRect(0, 0, 925, 665);
				launchScreenContainer.addChild(gameLaunchScreen);
				gameLaunchScreen.x = launchScreenContainer.width / 2 - gameLaunchScreen.width / 2;
				gameLaunchScreen.y = launchScreenContainer.height / 2 - gameLaunchScreen.height / 2;
				
				gameLaunchScreen.addEventListener('play', onPlayClick);
				gameLaunchScreen.addEventListener('practice', onPracticeClick);
				gameLaunchScreen.addEventListener('back', onBackClick);
				roomView.addPopUp(launchScreenContainer);
				
				// Hide progress alert.
				progressAlert.close(0);
			}
			
			function removeLaunchScreen():void
			{
				// Remove the game launch screen.
				gameLaunchScreen.removeEventListener('play', onPlayClick);
				gameLaunchScreen.removeEventListener('practice', onPracticeClick);
				gameLaunchScreen.removeEventListener('back', onBackClick);
				roomView.removePopUp(launchScreenContainer);
			}
			
			function onJoinGameQueueFail(e:SocketEvent):void
			{
				// Remove plugin action listeners.
				SocketClient.removePluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_SUCCESS, onJoinGameQueueSuccess);
				SocketClient.removePluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_FAIL, onJoinGameQueueFail);
				SocketClient.removePluginActionHandler(SocketEvent.LEAVE_GAME_QUEUE_SUCCESS, onLeaveGameQueueSuccess);
				
				// There was a failure to join the game queue.
				// Message user.
				SdgAlertChrome.show('Please try again.', 'Couldn\'t Join Game');
			}
			
			function onJoinGameQueueSuccess(e:SocketEvent):void
			{
				// Avatar successfully joined the game queue.
				// Make sure game room hasnt already been entered.
				if (mpGameRoomEntered) return;
				
				// Get parameters.
				var paramsXml:XML = new XML(e.params[e.params.action]);
				// Parse out users that are currently in the queue.
				var encodedUsersInQueue:String = paramsXml.usersInQueue;
				var userNames:Array = [];
				for each (var encodedVals:String in encodedUsersInQueue.split('|', 4))
				{
					var vals:Array = encodedVals.split(';', 2);
					userNames.push(vals[0]);
				}
				// Determine when the game queue will be launched.
				queueLaunchTime = paramsXml.startTime;
				maxQueueWait = 20000;
				timeUntilQueueLaunch = queueLaunchTime - ModelLocator.getInstance().serverDate.time;
				
				// Check if this is a joinSuccess for the local user or new users.
				if (!waitingForPlayersAlert)
				{
					// SHow a list of users in the queue while we wait for the game to launch.
					waitingForPlayersPopUp = new Sprite();
					waitingForPlayersPopUp.graphics.beginFill(0, 0.8);
					waitingForPlayersPopUp.graphics.drawRect(0, 0, 925, 665);
					waitingForPlayersAlert = new GameQueuePlayerList(userNames);
					waitingForPlayersAlert.title = 'Waiting For Players...';
					waitingForPlayersAlert.x = waitingForPlayersPopUp.width / 2 - waitingForPlayersAlert.width / 2;
					waitingForPlayersAlert.y = waitingForPlayersPopUp.height / 2 - waitingForPlayersAlert.height / 2;
					waitingForPlayersAlert.addEventListener(Event.CLOSE, onWaitingClose);
					waitingForPlayersPopUp.addChild(waitingForPlayersAlert);
					context.roomView.addPopUp(waitingForPlayersPopUp);
					
					// Create timer to update time value on waiting screen.
					queueTimer = new Timer(1000);
					queueTimer.addEventListener(TimerEvent.TIMER, onQueueTimer);
					queueTimer.start();
				}
				else
				{
					// Update the users in the queue list.
					waitingForPlayersAlert.userNames = userNames;
				}
				
				function onQueueTimer(e:TimerEvent):void
				{
					// Check if its time to remove the timer.
					if (timeUntilQueueLaunch < 1)
					{
						// Kill queue timer.
						queueTimer.removeEventListener(TimerEvent.TIMER, onQueueTimer);
						queueTimer.reset();
						queueTimer = null;
						return;
					}
					
					// Update time value on waiting screen.
					timeUntilQueueLaunch = queueLaunchTime - ModelLocator.getInstance().serverDate.time;
					if (waitingForPlayersAlert) waitingForPlayersAlert.timeValue = Math.round(timeUntilQueueLaunch / 1000);
				}
			}
			
			function onLeaveGameQueueSuccess(e:SocketEvent):void
			{
				// Get parameters.
				var paramsXml:XML = new XML(e.params[e.params.action]);
				// Parse out users that are currently in the queue.
				var encodedUsersInQueue:String = paramsXml.usersInQueue;
				var userNames:Array = [];
				for each (var encodedVals:String in encodedUsersInQueue.split('|', 4))
				{
					var vals:Array = encodedVals.split(';', 2);
					userNames.push(vals[0]);
				}
				
				if (waitingForPlayersAlert)
				{
					// Update the users in the queue list.
					waitingForPlayersAlert.userNames = userNames;
				}
			}
			
			function onLaunchGameQueue(e:SocketEvent):void
			{
				// Remove plugin action listeners.
				SocketClient.removePluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_SUCCESS, onJoinGameQueueSuccess);
				SocketClient.removePluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_FAIL, onJoinGameQueueFail);
				SocketClient.removePluginActionHandler(SocketEvent.LEAVE_GAME_QUEUE_SUCCESS, onLeaveGameQueueSuccess);
				// Remove waiting screen listeners.
				if (waitingForPlayersAlert) waitingForPlayersAlert.removeEventListener(Event.CLOSE, onWaitingClose);
				
				// Get params from launch event.
				// Might make sense to abstract this parsing of attributes in SocketClient.
				var paramsXml:XML = new XML(e.params[e.params.action]);
				var gameId:int = paramsXml.gameId;
				var gameRoomId:String = paramsXml.roomId;
				// Parse avatar colors.
				var encodedAvatarColors:Array = String(paramsXml.colors).split('|', 20);
				var avatarColors:Array = [];
				for each (var encodedColor:String in encodedAvatarColors)
				{
					var vals:Array = encodedColor.split(';', 2);
					var avatarId:int = vals[0];
					var color:uint = vals[1];
					avatarColors[avatarId] = color;
				}
				
				// Make sure the event is for the correct game.
				if (_isPractice)
				{
					if (gameId != _practiceGameId) return;
				}
				else if (gameId != _gameId)
				{
					return;
				}
				
				// Remove listener.
				SocketClient.removePluginActionHandler(SocketEvent.LAUNCH_GAME_QUEUE, onLaunchGameQueue);
				
				// Remove progress alert for "waiting for players"
				if (waitingForPlayersPopUp) context.roomView.removePopUp(waitingForPlayersPopUp);
				waitingForPlayersPopUp = null;
				waitingForPlayersAlert = null;
				
				// Create game params to pass to global variable.
				var gameParams:Object = {gameId: gameId, avatarColors: avatarColors, isPractice: (_isPractice) ? true : false};
				ModelLocator.getInstance().incomingGameParams = gameParams;
				
				// Enter the game room.
				RoomManager.getInstance().enterRoom(gameRoomId, false);
				// Set flag.
				mpGameRoomEntered = true;
			}
			
			function onAllTimePracticePlaysLoaded():void
			{
				// We have loaded data to determine how many times(ever) the local user has played practice mode for this game.
				practiceGamePlayCount = GamePlayCounter.getPlayCountAllTime(_practiceGameId);
				practiceGamePlayCountLoaded = true;
				
				// If the game launch screen has been loaded,
				// allow or disallow normal play based on practice play count.
				if (gameLaunchScreen)
				{
					if (Object(gameLaunchScreen)['allowPlay'] != null) Object(gameLaunchScreen).allowPlay = (practiceGamePlayCount > 0);
				}
			}
			
			function onWaitingClose(e:Event):void
			{
				// Leave the game queue.
				
				// Remove plugin action listeners.
				SocketClient.removePluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_SUCCESS, onJoinGameQueueSuccess);
				SocketClient.removePluginActionHandler(SocketEvent.JOIN_GAME_QUEUE_FAIL, onJoinGameQueueFail);
				SocketClient.removePluginActionHandler(SocketEvent.LAUNCH_GAME_QUEUE, onLaunchGameQueue);
				SocketClient.removePluginActionHandler(SocketEvent.LEAVE_GAME_QUEUE_SUCCESS, onLeaveGameQueueSuccess);
				// Remove waiting screen listeners.
				waitingForPlayersAlert.removeEventListener(Event.CLOSE, onWaitingClose);
				
				// Remove progress alert for "waiting for players"
				if (waitingForPlayersPopUp) context.roomView.removePopUp(waitingForPlayersPopUp);
				waitingForPlayersPopUp = null;
				waitingForPlayersAlert = null;
				
				// Send message to server, that we want to leave the game queue.
				// Do not wait for any response. Assume that we are no longer in the queue.
				SocketClient.getInstance().sendPluginMessage('avatar_handler', 'mpLeaveGameQueue', {avatarId: userAvatar.avatarId, gameId: gameId, launchPointId: item.id});
				
				// Have local avatar walk away from the queue area.
				var floorTileMap:TileMap = context.room.getMapLayer(RoomLayerType.FLOOR);
				var openTileCoordinate:Point = floorTileMap.getOpenTileCoordinate(TileSet.WALK_TILES.toString());
				if (openTileCoordinate) RoomManager.getInstance().userController.walk(openTileCoordinate.x, openTileCoordinate.y);
			}
		}
	}
}
package com.sdg.control.room
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.collections.QuickList;
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.controls.MVPAlert;
	import com.sdg.components.controls.RoomFullDialog;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.ISdgDialog;
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.components.dialog.MazeSkipDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.games.InvitePanel;
	import com.sdg.control.PDAController;
	import com.sdg.control.room.itemClasses.*;
	import com.sdg.events.ExternalGameEvent;
	import com.sdg.events.GameAttributesEvent;
	import com.sdg.events.HudEvent;
	import com.sdg.events.RoomCheckEvent;
	import com.sdg.events.RoomEnumEvent;
	import com.sdg.events.RoomItemActionEvent;
	import com.sdg.events.RoomManagerEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.ShowOverlayEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.factory.RoomBuilder;
	import com.sdg.game.counter.GamePlayCounter;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarAchievement;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Room;
	import com.sdg.model.SdgItem;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.net.socket.methods.SocketRoomMethods;
	import com.sdg.quest.QuestManager;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;

	import flash.display.StageDisplayState;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	import mx.core.FlexGlobals; // Non-SDG - Application to FlexGlobals
	import mx.events.CloseEvent;

	[Bindable]
	public class RoomManager extends EventDispatcher
	{
		public static const GAME_LIMIT_EXCEPTIONS:Array = [17, 18, 108, 67, 68];

		private var _preventSendItemAction:Boolean;
		private var _currentRoom:Room;
		private var _roomEnterStatus:uint = 0;
		private var _pendingRoomXML:XML;
		private var _pendingRoomId:String;
		private var _prevRoomId:String;
		private var _checkNumAvatars:Boolean = true;
		private var _roomContext:IRoomContext;
		//private var _hudVisible:Boolean = true;
		private var _lastGamePlayedId:uint = 0;
		public var itemCount:int = 0;
		private static var _isAwaitingEnterAction:Boolean = false;
		private static var _isAwaitingRoomRefresh:Boolean = false;

		private var _roomChangePreventionTargets:QuickList = new QuickList();
		private var _socketEnabled:Boolean = true;
		private var _userController:AvatarController;

		protected var roomBuilder:RoomBuilder = new RoomBuilder();
		public var socketMethods:SocketRoomMethods = new SocketRoomMethods();
		protected var userAvatar:Avatar = ModelLocator.getInstance().avatar;
		public var homeTurfAvatar:Avatar;

		private static var _instance:RoomManager;

		public function RoomManager()
		{
			if (_instance)
				throw new Error("RoomManager is a singleton class. Use 'getInstance()' to access the instance.");

			CairngormEventDispatcher.getInstance().addEventListener(ShowOverlayEvent.OVERLAY, onShowOverlayEvent);
		}

		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////

		public static function getInstance():RoomManager
		{
			if (_instance == null) _instance = new RoomManager();
			return _instance;
		}

		public static function isGameWithGamePlayLimit(gameId:int):Boolean
		{
			return GAME_LIMIT_EXCEPTIONS.indexOf(gameId) < 0;
		}

		public function allowRoomChange(target:Object):void
		{
			_roomChangePreventionTargets.removeValue(target);

			if (_roomEnterStatus == 1 && !_roomChangePreventionTargets.length)
			{
				startRoomEnter();
			}
		}

		public function preventRoomChange(target:Object):void
		{
			_roomChangePreventionTargets.push(target);
		}

		public function enterRoom(roomId:String, checkNumAvatars:Boolean = true):void
		{
			// Ignore if a request has already been made for this roomId.
			if (roomId == pendingRoomId || roomId == currentRoomId) return;
			if (_isAwaitingEnterAction == true) return;
			if (_isAwaitingRoomRefresh == true) return;

			// If trying to enter room 0,
			// show the world map and do not
			// enter a room.
			if (roomId == "public_0")
			{
				dispatchEvent(new RoomManagerEvent(RoomManagerEvent.REQUEST_FOR_WORLD_MAP));
				return;
			}

			// Check if the room is the local user's private room (home turf).
			// If it is then dispatch a user action to the server.
			//if (roomId == userAvatar.privateRoom)
			//{
				//var params:Object = new Object();
				//params.actionType = UserActionTypes.ENTER_MY_PRIVATE_ROOM;
				//params.actionValue = '1';
				//if (Constants.QUEST_ENABLED == true) SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.USER_ACTION, params);
			//}

			// Check if entering the maze from the football field.
			if (roomId == 'public_1000' && _currentRoom.id == 'public_121')
			{
				// User MUST be registered to enter the maze.
				if (userAvatar.membershipStatus == MembershipStatus.GUEST)
				{
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}

				// If avatar has already completed the maze,
				// give them an option to skip.
				var achievementId:int = 574;
				var enteredLockerRoom:AvatarAchievement = QuestManager.getActiveQuest(achievementId);
				var mazeSkipDialog:ISdgDialog;
				if (enteredLockerRoom != null && enteredLockerRoom.isComplete)
				{
					// Message to avatar and allow them to skip maze.
					_isAwaitingEnterAction = true;
					var mazeSkipParams:Object = {};
					mazeSkipParams.onButton1 = onMazeSkip;
					mazeSkipParams.onButton2 = onMazeContinue;
					mazeSkipDialog = MainUtil.showDialog(MazeSkipDialog, mazeSkipParams);
					return;
				}

				function onMazeSkip():void
				{
					// Re-route avatar to locker room.
					roomId = 'public_144';
					mazeSkipDialog.close();
					continueEnterRoom();
				}

				function onMazeContinue():void
				{
					mazeSkipDialog.close();
					continueEnterRoom();
				}
			}

			// Log when entering the stadium. Should just be needed
			// This can't be done via a unique room entries since
			// there are multiple error states people could see.
			if (roomId == 'public_115')
			{
				LoggingUtil.sendClickLogging(LoggingUtil.ROOM_ENTER_CLICK_STADIUM);
			}

			continueEnterRoom();

			function continueEnterRoom():void
			{
				_pendingRoomId = roomId;
				_roomEnterStatus = 1;
				_checkNumAvatars = checkNumAvatars;
				_isAwaitingEnterAction = false;
				_isAwaitingRoomRefresh = true;

				// Dispatch change event.
				// private room editor listens to this to allow the user a chance to cancel a room exit
				dispatchEvent(new RoomManagerEvent(RoomManagerEvent.ENTER_ROOM_INIT));

				var roomIdArray:Array = roomId.split("_");
				var roomIdNum:int = roomIdArray[0] == "public" ? roomIdArray[1] : 1;
				CairngormEventDispatcher.getInstance().addEventListener(RoomCheckEvent.ROOM_CHECKED, onRoomChecked);
				CairngormEventDispatcher.getInstance().dispatchEvent(new RoomCheckEvent(userAvatar.avatarId, roomIdNum));
			}
		}

		public function isTeleportingForbiddenRoom(roomId:String = null):Boolean
		{
			if (roomId == null)
				roomId = currentRoomId;

			var array:Array = roomId.split("public_");
			if (array.length > 1)
			{
				var rId:int = array[1];
				if ((rId >= 148 && rId <= 152))
					return true;
				if ((rId >= 157 && rId <= 164))
					return true;
			}
			return false;
		}

		public function isUnderwaterRoom(roomId:String = null):Boolean
		{
			if (roomId == null)
				roomId = currentRoomId;

			var array:Array = roomId.split("public_");
			if (array.length > 1)
			{
				var rId:int = array[1];
				if ((rId >= 1100 && rId <= 1119) || (rId >= 1130 && rId <= 1136) || rId == 146)
					return true;
			}
			return false;
		}

		public function isMazeRoom(roomId:String = null):Boolean
		{
			if (roomId == null)
				roomId = currentRoomId;

			var array:Array = roomId.split("public_");
			if (array.length > 1)
			{
				var rId:int = array[1];
				if (rId >= 1000 && rId <= 1020)
					return true;
			}
			return false;
		}

		public function exitRoom():void
		{
			if (_currentRoom)
			{
				removeSessionListeners();
				socketMethods.exit();
				_prevRoomId = _currentRoom.id;
				_currentRoom.removeAllItems();
				_currentRoom.removeAllClientItems();
				currentRoom = null;
			}
		}

		public function sendChat(text:String):void
		{
			userController.chat(text);
		}

		public function sendRoomUpdate():void
		{
			//_socketEnabled = true;
			//addSessionListeners();

			socketMethods.sendEnumUpdated();
		}

		public function sendItemAction(item:SdgItem, action:String, params:Object, consequence:Object = null):void
		{
			socketMethods.sendItemAction(item.itemClassId, item.id, action, params, consequence);
		}

		public function updateRoomTheme(params:Object, roomController:RoomController):void
		{
			// Set the pending room XML.
			_pendingRoomXML = XML(XML(params.response).room);

			// turn off tile tiggers
			userController.enableTileTriggers = false;

			// if layout not the same as old layout, remove items from room
			//if (_currentRoom.layoutId != _pendingRoomXML.roomId)
			//	_currentRoom.removeAllInventoryItems();

			roomBuilder.updateRoom(_pendingRoomXML);

			roomController.context.setUpRoom();
			roomController.setupRoomSound(_currentRoom);

			//socketMethods.getEnumeration();
		}

		public function handleUserAtGameLimit():void
		{
			// The user has reached their game play limit for the day.
			// Show an MVP upsell.
			var mvpButtonId:int = 3746;
			var mvpDialog:CustomMVPAlert = CustomMVPAlert.show(AssetUtil.GetGameAssetUrl(99, 'mvp_upsell_games.swf'), mvpButtonId, onMvpUpsellClose);
			LoggingUtil.sendClickLogging(3745);
			return;

			function onMvpUpsellClose(e:Object):void
			{
				// Check if we should go to mvp page.
				var identifier:int = 0;
				if (e['detail']) identifier = e.detail;
				if (identifier == mvpButtonId) MainUtil.goToMVP(mvpButtonId);
			}
		}

		public function isUserAtGamePlayLimit(userMembershipStatis:int, gameId:int):Boolean
		{
			if (userMembershipStatis != MembershipStatus.PREMIUM)
			{
				// Create Exception Games
				var exception:Boolean = !isGameWithGamePlayLimit(gameId);

				var gamePlayCount:int = GamePlayCounter.getPlayCount(gameId);
				if ((gamePlayCount > (GamePlayCounter.MAX_FREE_PLAYS_PER_DAY - 1)) && (!exception))
				{
					// The user has reached their game play limit for the day.
					return true;
				}
			}

			return false;
		}

		public function loadGame(gameId:int, achievementId:int=0, avatarId:int=0, team1ItemId:int = 0, team2ItemId:int = 0, checkGamePlayLimit:Boolean = false):void
		{
			if (!ExternalInterface.available) return;

			// If we are currently entering a room, ignore this action.
			if (isEnteringRoom) return;

			// Make sure the local user has not reached their daily game play limit.
			if (checkGamePlayLimit && isUserAtGamePlayLimit(userAvatar.membershipStatus, gameId))
			{
				// The user has reached their game play limit for the day.
				// Show an MVP upsell.
				handleUserAtGameLimit();
				return;
			}

			// Send the stage to normal display state.
			FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.NORMAL;

			FlexGlobals.topLevelApplication.frameRate = .01;
			avatarId = (avatarId == 0) ? userAvatar.avatarId : avatarId;
			_lastGamePlayedId = gameId;

			CairngormEventDispatcher.getInstance().dispatchEvent(new GameAttributesEvent(avatarId, gameId, achievementId, team1ItemId, team2ItemId));

			SocketClient.sendMessage("room_manager","startGame","gameEvent", {gameId:gameId, avatarId:avatarId, achievementId:achievementId, team1Id:team1ItemId, team2Id:team2ItemId});

			// Dispatch an event that signifies a game is being loaded.
			dispatchEvent(new ExternalGameEvent(ExternalGameEvent.LOAD_GAME));

			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.EXIT_ROOM));

			// leave any invite panels we are in
			var invitePanel:InvitePanel = InvitePanel(FlexGlobals.topLevelApplication.mainLoader.child.invitePanel);
			if (invitePanel.visible)
				invitePanel.closeAndUpdatePanels();
		}

		public function teleportToRoom(roomId:String):Boolean
		{
			// if the room you are teleporting to is maze room
			if (isMazeRoom(roomId))
			{
				// if current room is maze room
				if (isMazeRoom())
				{
					SdgAlertChrome.show("Sorry, no hopping rooms in the maze.", "Time Out");
					LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_BLOCKED);
					return false;
				}
				else
				{
					// send to football field
					roomId = "public_121";
					LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_CLOSEST_POINT);
				}

			}
			else if (isUnderwaterRoom(roomId))
			{
				// if current room is underwater room
				if (isUnderwaterRoom())
				{
					SdgAlertChrome.show("Sorry, no hopping underwater.", "Time Out");
					LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_BLOCKED);
					return false;
				}
				else
				{
					// send to pier
					roomId = "public_145";
					LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_CLOSEST_POINT);
				}
			}
			else if (isTeleportingForbiddenRoom(roomId))
			{
				SdgAlertChrome.show("Jumping to this location is not permitted", "Time Out");
				LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_BLOCKED);
				return false;
			}
			else if (roomId.indexOf('game') == 0)
			{
				// Trying to teleport to a game room.
				// DO not allow this.

				// Try to determine which game room the user is trying to teleport to.
				// Try to teleport to the hub room of that game.
				var vals:Array = roomId.split('_');
				var gameId:int = vals[1];
				switch (gameId)
				{
					case 67:
					case 68:
						// Trying to jump to skae game.
						// Send to skate park.
						roomId = 'public_202';
						LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_SUCCESS);
						break;
					default:
						SdgAlertChrome.show("Jumping to this location is not permitted", "Time Out");
						LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_BLOCKED);
						return false;
				}
			}
			else
			{
				LoggingUtil.sendClickLogging(LoggingUtil.TELEPORT_SUCCESS);
			}

			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			return true;
		}

		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////

		protected function onRoomChecked(event:RoomCheckEvent):void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(RoomCheckEvent.ROOM_CHECKED, onRoomChecked);

			switch (event.status)
			{
				case 1:
					// Attempt enter.
					allowRoomChange(this);
					break;
				case 419: // does not own item
					MainUtil.showDialog(InteractiveDialog, {url:Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=7",id:""},false,false);
					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
				case 420: // owns item but is not wearing it
					MainUtil.showDialog(InteractiveDialog, {url:Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=8",id:""},false,false);
					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
				case 421: // does not own badge
					var code:int = event.codeId;
					//MainUtil.showDialog(InWorldShopDialog, "swfs/snorkel_popUp.swf");
					//MainUtil.showDialog(InWorldShopDialog, Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=" + event.codeId);
					if (code == 13)
					{
						MainUtil.showDialog(InteractiveDialog, {url:Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=13",id:""},false,false);
					}
					else
					{
						MainUtil.showDialog(InteractiveDialog, {url:Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=9",id:""},false,false);
					}
					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
				case 423: // Is Not MVP
					var codeId:int = event.codeId;
					// TBD for October Event - Check for code id
					// codeId=10, block on mavericks arcade
					// codeId=11, block on dugout - ***obselete***
					// codeId=12, block on mavericks room - custom mvp upsell
					if (userAvatar.membershipStatus == MembershipStatus.GUEST)
					{
						MainUtil.showDialog(SaveYourGameDialog);
					}
					else if (codeId == 10)
					{
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_MAVS_ARCADE);
						var alert:MVPAlert = MVPAlert.show("Maverick's Arcade is for MVP Members only. Become part of the MVP team now " +
								"to unlock all the awesome sports and arcade games in Action AllStars!", "Join the Team!", onClose);
						alert.addButton("Become A Member", LoggingUtil.MVP_UPSELL_CLICK_MAVS_ARCADE, 250);
					}
					else if (codeId == 11)
					{
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_HOME_DUGOUT);
						var alert2:MVPAlert = MVPAlert.show("This room is for MVP Members only. Become part of the MVP team now " +
								"to unlock all the awesome sports and arcade games in Action AllStars!", "Join the Team!", onClose);
						alert2.addButton("Become A Member", LoggingUtil.MVP_UPSELL_CLICK_HOME_DUGOUT, 250);
					}
					else if (codeId == 12)
					{
						LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_MAVERICKS);
						CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/82/gameFile/mvp_upsell_" + codeId + ".swf",
											LoggingUtil.MVP_UPSELL_CLICK_MAVERICKS, onClose);
					}

					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
				case 425: // Can't Enter Mini-Maze
					//TODO: remove this case when Yves takes out room change.
					allowRoomChange(this);
					break;
				case 426: //Can't enter Scavenger Maze
					MainUtil.showDialog(InteractiveDialog, {url:Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=5",id:""},false,false);
					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
				// Needs to be wearing zombie outfit to enter Diamonds run
				// case 428 is owns but is not wearing. case 427 is doesn't own
				case 427:
					MainUtil.showDialog(InteractiveDialog, {url:Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=10",id:""},false,false);
					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
				case 428:
					var retDialog:ISdgDialog = MainUtil.showDialog(InteractiveDialog, {url:Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=11",id:""},false,false);
					retDialog.addEventListener(Event.CLOSE,onCloseEquipZombieOutfit,false,0,true);
					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
				default: //
					//MainUtil.showDialog(InWorldShopDialog, Environment.getApplicationUrl() + "/test/static/clipart/codeLogoTemplate?codeId=1");
					_pendingRoomId = "";
					_isAwaitingRoomRefresh = false;
					break;
			}

			function onCloseEquipZombieOutfit(event:Event):void
			{
				PDAController.getInstance().showAvatar(ModelLocator.getInstance().avatar);
			}

   			function onClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;

				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_MAVS_ARCADE ||
				    identifier == LoggingUtil.MVP_UPSELL_CLICK_HOME_DUGOUT ||
				    identifier == LoggingUtil.MVP_UPSELL_CLICK_MAVERICKS)
					MainUtil.goToMVP(identifier);
			}
		}

		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////

		private function startRoomEnter():void
		{
			// first see how many user's we have in this room
			socketMethods.addEventListener(SocketRoomEvent.NUM_AVATARS, roomEnterHandler);
			socketMethods.getAvatarCountInRoom(_pendingRoomId);
		}

		private function roomEnterHandler(event:SocketRoomEvent):void
		{
			// Remove avatar count listener.
			var _avatarXML:XML = XML(event.params.numAvatars);
			socketMethods.removeEventListener(SocketRoomEvent.NUM_AVATARS, roomEnterHandler);

			// room lock logic
			var roomIdArray:Array = _pendingRoomId.split("_");
			if (roomIdArray[0] == "private") // if the room is a private room
			{
				var roomAvatarId:int = roomIdArray[1];
				if (roomAvatarId != userAvatar.avatarId) // if this is not your room
				{
					var lockMode:int = int(_avatarXML.lockMode);

					// room lock set to 3 = only owner can enter
					// room lock set to 1 = only buddies can enter

					if (lockMode == Constants.TURF_ACCESS_PRIVATE || (lockMode == Constants.TURF_ACCESS_FRIENDS && _avatarXML.isFriend == 0))
					{
						var lockMessage:String = lockMode == Constants.TURF_ACCESS_PRIVATE ? "This turf is locked." : "This turf is open to friends only.";
						_pendingRoomId = "";

						SdgAlertChrome.show(lockMessage, "Sorry");
						_isAwaitingRoomRefresh = false;
						return;
					}
				}
			}

			if (int(_avatarXML.numAvatars) >= int(_avatarXML.maxAvatars) && _checkNumAvatars)
			{
				var linkId:Object = LoggingUtil.roomFullLinkIdMapping[_pendingRoomId];

				if (linkId != null)
					LoggingUtil.sendClickLogging(linkId as int);

				RoomFullDialog.show(_pendingRoomId);
				_pendingRoomId = "";		// allows reentry into same room from world after room full rejection
				//SdgAlert.show("Sorry, this room is currently full. Try again later.", "Room Full");
				//SdgAlertChrome.show("Oops! This room is full. You may want to try another server!", "Room Full");
				_isAwaitingRoomRefresh = false;
				return;
			}

			// if the invite panel is up - close it
			if (userController.invitePanelOn)
			{
			    var invitePanel:InvitePanel = InvitePanel(FlexGlobals.topLevelApplication.mainLoader.child.invitePanel);
                invitePanel.closeAndUpdatePanels();
			}

			dispatchEvent(new RoomManagerEvent(RoomManagerEvent.ENTER_ROOM_START));

			CairngormEventDispatcher.getInstance().dispatchEvent(new HudEvent(HudEvent.ROOM_CHANGE, null));

			_roomEnterStatus = 2;
			socketEnabled = true;
			socketMethods.addEventListener(SocketRoomEvent.CONFIG, enterConfigHandler);
			socketMethods.getConfig(_pendingRoomId);
		}

		private function enterConfigHandler(event:SocketRoomEvent):void
		{
			// Remove config listener.
			socketMethods.removeEventListener(SocketRoomEvent.CONFIG, enterConfigHandler);

			// Exit the previous room.
			removeSessionListeners();
			socketMethods.exit();

			// Set the pending room XML.
			_pendingRoomXML = XML(XML(event.params.response).room);
			trace("\n\nRoom Config:", _pendingRoomXML.toXMLString() + "\n\n");

			// Join room.
			socketMethods.addEventListener(SocketRoomEvent.JOIN, enterJoinHandler);
			socketMethods.join(_pendingRoomId);
		}

		private function enterJoinHandler(event:SocketRoomEvent):void
		{
			// turn off tile tiggers while we join the room
			userController.enableTileTriggers = false;

			_roomEnterStatus = 0;

			// Remove join listener.
			socketMethods.removeEventListener(SocketRoomEvent.JOIN, enterJoinHandler);

			// Remove all items in the previous room.
			if (_currentRoom)
			{
				_currentRoom.removeAllItems();
				_currentRoom.removeAllClientItems();
			}

			// Build room.
			roomBuilder.buildRoom(_pendingRoomXML);
			var room:Room = roomBuilder.getRoom();

			// Set the new room as current.
			currentRoom = room;

			dispatchEvent(new RoomManagerEvent(RoomManagerEvent.ENTER_ROOM_COMPLETE));

			// Add listeners for socket events.
			addSessionListeners();

			// Get enumeration.
			socketMethods.getEnumeration();
		}

		private function onShowOverlayEvent(ev:ShowOverlayEvent):void
		{
			if (currentRoomId && userController.behaviorRunning)
			{
				userController.stopWalking();
			}
		}

		private function addSessionListeners():void
		{
			if (!_socketEnabled) return;

			socketMethods.addEventListener(SocketRoomEvent.JOIN, userJoinHandler);
			socketMethods.addEventListener(SocketRoomEvent.EXIT, userExitHandler);
			socketMethods.addEventListener(SocketRoomEvent.ENUMERATION, enumerationHandler);
			socketMethods.addEventListener(SocketRoomEvent.AVATAR_ACTION, itemActionHandler);
			socketMethods.addEventListener(SocketRoomEvent.DOODAD_ACTION, itemActionHandler);
			socketMethods.addEventListener(SocketRoomEvent.UPDATE, itemUpdateHandler);
			socketMethods.addEventListener(SocketRoomEvent.BOT_ADDED, botAddedHandler);
			socketMethods.addEventListener(SocketRoomEvent.BOT_REMOVED, botRemovedHandler);
		}

		private function removeSessionListeners():void
		{
			socketMethods.removeEventListener(SocketRoomEvent.JOIN, userJoinHandler);
			socketMethods.removeEventListener(SocketRoomEvent.EXIT, userExitHandler);
			socketMethods.removeEventListener(SocketRoomEvent.ENUMERATION, enumerationHandler);
			socketMethods.removeEventListener(SocketRoomEvent.AVATAR_ACTION, itemActionHandler);
			socketMethods.removeEventListener(SocketRoomEvent.DOODAD_ACTION, itemActionHandler);
			socketMethods.removeEventListener(SocketRoomEvent.UPDATE, itemUpdateHandler);
			socketMethods.addEventListener(SocketRoomEvent.BOT_ADDED, botAddedHandler);
			socketMethods.addEventListener(SocketRoomEvent.BOT_REMOVED, botRemovedHandler);
		}

		////////////////////
		// GET/SET FUNCTIONS
		////////////////////

		public function get currentRoom():Room
		{
			return _currentRoom;
		}

		protected function set currentRoom(value:Room):void
		{
			if (_currentRoom)
			{
				_currentRoom.removeEventListener(RoomEnumEvent.ENUM_REFRESH, onRoomEnumRefressh);
				_prevRoomId = _currentRoom.id;
			}

			_currentRoom = value;
			if (_currentRoom != null) _currentRoom.addEventListener(RoomEnumEvent.ENUM_REFRESH, onRoomEnumRefressh);
			_pendingRoomId = null;
		}

		public function get currentRoomId():String
		{
			return (_currentRoom) ? _currentRoom.id : null;
		}


		/**
		 * Return path to current tutorial help text xml for this room
		 * or null
		 */
		public function get currentbgHelpTextUrl():String
		{
			return (_currentRoom) ? _currentRoom.bgHelpTextUrl : null;
		}

		/**
		 * Return path to current tutorial help swf for this room
		 * or null
		 */
		public function get currentbgSwfUrl():String
		{
			return (_currentRoom) ? _currentRoom.bgSwfUrl : null;
		}

		public function get pendingRoomId():String
		{
			return _pendingRoomId;
		}

		public function get prevRoomId():String
		{
			return _prevRoomId;
		}

		public function get socketEnabled():Boolean
		{
			return _socketEnabled;
		}

		public function set socketEnabled(value:Boolean):void
		{
			if (value != _socketEnabled)
			{
				_socketEnabled = value;

				if (_socketEnabled)
				{
					// If we're connected to a room, add socket event
					// listeners and get the latest enumeration.
					if (_currentRoom && !_pendingRoomId)
					{
						addSessionListeners();
						socketMethods.getEnumeration();

						// Set the avatar status to available.
						userAvatar.statusId = Avatar.AVAILABLE_STATUS;
					}
				}
				else
				{
					// Set the avatar status to away.
					userAvatar.statusId = Avatar.AWAY_STATUS;

					// Remove socket event listeners.
					removeSessionListeners();
				}
			}
		}

		public function get userController():AvatarController
		{
			return _userController;
		}

		public function set userController(controller:AvatarController):void
		{
			_userController = controller;

			// increase speed for skateboarders
			// WHAT THE $@&%#@! ????? - Tommy
			if (_userController.avatar && _userController.avatar.isWearingSkateboardingOutfit)
				_userController.walkSpeedMultiplier = 1.75;
		}

		public static function get isEnteringRoom():Boolean
		{
			return (_isAwaitingEnterAction || _isAwaitingRoomRefresh);
		}

		public function get roomContext():IRoomContext
		{
			return _roomContext;
		}
		public function set roomContext(value:IRoomContext):void
		{
			_roomContext = value;
		}

		////////////////////
		// EVENT HANDLERS
		////////////////////

		private function enumerationHandler(event:SocketRoomEvent):void
		{
			// Update room elements.
			roomBuilder.buildEnumeration(XML(event.params.roomEnumeration));
			// turn on tile triggers
			userController.enableTileTriggers = true;
		}

		private function userJoinHandler(event:SocketRoomEvent):void
		{
			// Add the entered avatar to the room.
			roomBuilder.buildItems(XML(event.params.userAdded));
		}

		private function userExitHandler(event:SocketRoomEvent):void
		{
			// Remove the exited avatar.
			var avatarXML:XMLList = XML(event.params.userRemoved).avatar;
			_currentRoom.removeAvatarById(avatarXML.aId);
		}

		private function botAddedHandler(event:SocketRoomEvent):void
		{
			roomBuilder.buildItems(XML(event.params.botAdded));
		}

		private function botRemovedHandler(event:SocketRoomEvent):void
		{
			var botXML:XMLList = XML(event.params.botRemoved).i;
			_currentRoom.removeInventoryItemById(botXML.Id);
		}

		private function itemActionHandler(event:SocketRoomEvent):void
		{
			var params:Object = event.params;
			var actionXML:XML;
			var item:SdgItem;

			if (event.type == SocketRoomEvent.AVATAR_ACTION)
			{
				actionXML = XML(params.avatarAction);

				if (actionXML.action == "jab")
					item = _currentRoom.getAvatarById(actionXML.toAvatarId);
				else if (actionXML.action == "acceptInvite")
					item = _currentRoom.getAvatarById(actionXML.inviterAvatarId);
				else if (actionXML.action == "updateInvitePanels" || actionXML.action == "startBoardGame" || actionXML.action == "boardGameAction")
					item = userAvatar;
				else
					item = _currentRoom.getAvatarById(actionXML.id);
			}
			else if (event.type == SocketRoomEvent.DOODAD_ACTION)
			{
				actionXML = XML(params.doodadAction);
				if (actionXML.action == "jab")
					item = _currentRoom.getAvatarById(actionXML.toAvatarId);
				else item = _currentRoom.getInventoryItemById(actionXML.id);
			}
			else
			{
				trace("RoomManager: Unable to parse item action.");
				return;
			}

			if (item)
			{
				dispatchEvent(new RoomItemActionEvent(
					RoomItemActionEvent.ROOM_ITEM_ACTION, item, actionXML.action, actionXML));
			}
		}

		private function itemUpdateHandler(event:SocketRoomEvent):void
		{
			roomBuilder.buildItem(XML(event.params.update));
		}

		private function onRoomEnumRefressh(e:RoomEnumEvent):void
		{
			_isAwaitingRoomRefresh = false;
		}

	}
}

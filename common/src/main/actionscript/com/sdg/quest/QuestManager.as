package com.sdg.quest
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.controls.MVPAlert;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.dialog.TeamSelectDialog;
	import com.sdg.control.PDAController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.GameLauncherEvent;
	import com.sdg.events.PDACallEvent;
	import com.sdg.events.QuestCardEvent;
	import com.sdg.events.QuestMovieEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Achievement;
	import com.sdg.model.AchievementCollection;
	import com.sdg.model.AchievementCriteria;
	import com.sdg.model.AchievementMetricAttributeType;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarAchievement;
	import com.sdg.model.AvatarAchievementCollection;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.PDACallModel;
	import com.sdg.model.QuestDeliveryMethodId;
	import com.sdg.model.QuestProvider;
	import com.sdg.model.QuestProviderCollection;
	import com.sdg.model.User;
	import com.sdg.model.UserActionTypes;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.npc.NPCClickHandlers;
	import com.sdg.npc.NPCEvent;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.IRoomView;
	import com.sdg.view.MissionResolveMovieContainer;
	import com.sdg.view.PopUpTransition;
	import com.sdg.view.QuestCard;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.events.CloseEvent;

	public class QuestManager extends EventDispatcher
	{
		public static const AVAILABLE_QUESTS_UPDATE:String = 'available quests update';
		public static const ACTIVE_QUESTS_UPDATE:String = 'active quests update';
		public static const QUEST_COMPLETE:String = 'quest complete';
		public static const LOAD_ACTIVE_QUESTS:String = 'load active quests';
		public static const INTRO_QUEST_ID:uint = 512;
		public static const TEAM_SELECT_QUEST_ID:uint = 514;
		public static const CAPTURE_THE_FLAG_QUEST_ID:uint = 556;
		public static const REGISTRATION_QUEST_ID:uint = 521;
		public static const HOT_DOG_HEIST_MISSION_ID:int = 560;
		public static const CATCH_A_THIEF_QUEST_ID:uint = 567;
		public static const NFL_PUZZLE_1_QUEST_ID:uint = 570;
		public static const NFL_PUZZLE_2_QUEST_ID:uint = 571;
		public static const NFL_PUZZLE_3_QUEST_ID:uint = 572;
		public static const ZOMBIE_BOSS_QUEST_ID:uint = 635;
		public static const KICKER_TRY_OUT_QUEST_ID:uint = 684;
		public static const TEAM_SELECT_NPC_ID:String = '585';
		public static const SCUBA_CERTIFICATION_MISSION_ID:int = 576;
		public static const NBA_SCAVENGER_HUNT_MISSION_ID:int = 586;
		public static const TRICK_OR_TREAT_MISSION_ID:int = 609;
		public static const ZOMBIE_HIDE_AND_SEEK_MISSION_ID:int = 644;
		public static const TURKEY_HIDE_AND_SEEK_MISSION_ID:int = 661;
		public static const HAT_HIDE_AND_SEEK_MISSION_ID:int = 690;
		
		protected static var _instance:QuestManager;
		
		private static var _availableQuests:AchievementCollection;
		private static var _questProviders:QuestProviderCollection;
		private static var _activeUserQuests:AvatarAchievementCollection;
		private static var _roomView:IRoomView;
		private static var _loadingAvailableQuests:Boolean = false;
		private static var _questDeliverMethods:Array;
		private static var _postQuestResolveHandlers:Array;
		private static var _questIsDeliveredFlags:Array;
		private static var _questAcceptHandlers:Array;
		private static var _inventoryItemResolveMap:Array;
		private static var _inventoryItemResolveMvpLockMap:Array;
		private static var _inventoryItemResolveAchievementMap:Array;
		
		public function QuestManager()
		{
			if (_instance == null)
			{
				super();
			}
			else
			{
				throw new Error("QuestManager is a singleton class. Use 'getInstance()' to access the instance.");
			}
		}
		
		public static function getInstance():QuestManager
		{
			if (_instance == null) _instance = new QuestManager();
			return _instance;
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public static function init():void
		{
			if (Constants.QUEST_ENABLED == false) return;
			
			_questIsDeliveredFlags = [];
			
			// Setup quest delivery methods.
			_questDeliverMethods = [];
			_questDeliverMethods[QuestDeliveryMethodId.PDA] = deliverQuestPDA;
			_questDeliverMethods[QuestDeliveryMethodId.NPC] = deliverQuestNPC;
			_questDeliverMethods[QuestDeliveryMethodId.IMMEDIATE] = deliverQuestImmediate;
			_questDeliverMethods[QuestDeliveryMethodId.IMMEDIATE_CARD] = deliverQuestImmediateCard;
			
			// Setup post quest resolve methods.
			_postQuestResolveHandlers = [];
			_postQuestResolveHandlers[INTRO_QUEST_ID] = onPostIntroResolve;
			
			// Setup quest accept handlers.
			_questAcceptHandlers = [];
			_questAcceptHandlers[REGISTRATION_QUEST_ID] = onRegistrationQuestAccept;
			_questAcceptHandlers[INTRO_QUEST_ID] = onIntroQuestAccept;
			
			// Default.
			_inventoryItemResolveMap = [];
			_inventoryItemResolveMvpLockMap = [];
			_inventoryItemResolveAchievementMap = [];
			
			loadActiveQuests();
			
			// Listen for socket events that indicate a new completed quest.
			RoomManager.getInstance().socketMethods.addEventListener('achievementComplete', onAchievementComplete);
			
			// Listen for socket events that indicate a new accepted quest.
			RoomManager.getInstance().socketMethods.addEventListener('achievementAccepted', onAchievementAccept);
			
			// Listen for show quest card events.
			PDAController.getInstance().pdaView.addEventListener(QuestCardEvent.SHOW_CARD, onPDAShowQuestCard);
			
			// Listen for show cutscene event.
			PDAController.getInstance().pdaView.addEventListener(QuestMovieEvent.SHOW_MOVIE, onShowQuestMovie);
			
			// If the local user is already a registered member,
			// complete the registration quest by dispatching a user
			// action for registration.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus != MembershipStatus.GUEST)
			{
				var params:Object = new Object();
				params.actionType = UserActionTypes.REGISTRATION_COMPLETE;
				params.actionValue = '1';
				SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.USER_ACTION, params);
			}
		}
		
		public static function destroy():void
		{
			// Remove event listeners.
			RoomManager.getInstance().socketMethods.removeEventListener('achievementComplete', onAchievementComplete);
			RoomManager.getInstance().socketMethods.removeEventListener('achievementAccepted', onAchievementAccept);
			PDAController.getInstance().pdaView.removeEventListener(QuestCardEvent.SHOW_CARD, onPDAShowQuestCard);
			PDAController.getInstance().pdaView.removeEventListener(QuestMovieEvent.SHOW_MOVIE, onShowQuestMovie);
		}
		
		public static function getAvailableQuest(questId:uint):Achievement
		{
			return _availableQuests.getFromId(questId);
		}
		
		public static function getActiveQuest(questId:uint):AvatarAchievement
		{
			if (_activeUserQuests == null) return null;
			return _activeUserQuests.getFromId(questId);
		}
		
		public static function acceptQuest(questId:uint):void
		{
			// Make sure it's not already an active quest.
			if (_activeUserQuests != null && _activeUserQuests.getFromId(questId) != null) return;
			
			var params:Object = new Object();
			params.achievementId = questId.toString();
			SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.ACCEPT_QUEST, params);
		}
		
		public static function getInventoryItemResolveStatus(iventoryItemId:int):int
		{
			// -1: NONE
			// 0: Defualt (Currently a green star as of 09/28/2010)
			// 1+: Specific types of resolve.
			
			var resolveStatus:int = (_inventoryItemResolveMap[iventoryItemId] != null) ? _inventoryItemResolveMap[iventoryItemId] : -1;
			return resolveStatus;
		}
		
		////////////////////
		// PRIVATE METHODS
		////////////////////
		
		private static function extractQuestProviders(achievments:AchievementCollection):void
		{
			// Extract QuestProvider objects.
			var userAchievements:AchievementCollection = achievments;
			var achievement:Achievement;
			var questProviders:QuestProviderCollection;
			var questProvider:QuestProvider;
			var i:int = 0;
			var i2:int;
			var len:int = userAchievements.length;
			var len2:int;
			for (i; i < len; i++)
			{
				achievement = userAchievements.getAt(i);
				questProviders = achievement.questProviders;
				i2 = 0;
				len2 = questProviders.length;
				for (i2; i2 < len2; i2++)
				{
					questProvider = questProviders.getAt(i2);
					questProvider.addAchievement(achievement);
					addQuestProvider(questProvider);
				}
			}
			
			function addQuestProvider(questProvider:QuestProvider):void
			{
				// Make sure the collection exists.
				if (_questProviders == null) _questProviders = new QuestProviderCollection();
				// Make sure a quest provider with the same id does not exist in the collection.
				var currentQuestProvider:QuestProvider = _questProviders.getFromId(questProvider.id);
				if (currentQuestProvider == null)
				{
					// Append the new quest provider to the collection.
					_questProviders.push(questProvider);
				}
				else
				{
					// There is already a quest provider with the same id in the collection.
					// Merge the achievements of the two quest providers.
					currentQuestProvider.mergeAchievements(questProvider);
				}
			}
		}
		
		private static function loadAvailableQuests():void
		{
			if (Constants.QUEST_ENABLED == false) return;
			
			// Make sure we arent already loading available quests.
			if (_loadingAvailableQuests == true) return;
			
			// Set flag.
			_loadingAvailableQuests = true;
			
			// Query server for user achievements.
			var avatarId:int = ModelLocator.getInstance().avatar.avatarId;
			var url:String = 'http://' + Environment.getApplicationDomain() + '/test/quest/listAvailable?avatarId=' + avatarId;
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(request);
			
			function onComplete(e:Event):void
			{
				// Recieved user achievements response.
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				// Extract XML.
				var xml:XML = new XML(urlLoader.data);
				var status:int = xml.@status;
				
				// Make sure we got a valid response.
				if (status != 1) return;
				
				// Recieved valid response.
				// Parse the XML into a collection of achievments.
				var availableQuests:AchievementCollection = AchievementCollection.ParseMultipleAchievementsXML(xml.achievements);
				
				// Extract QuestProvider objects.
				extractQuestProviders(availableQuests);
				
				// Set new value.
				userAchievements = availableQuests;
				
				// Set flag.
				_loadingAvailableQuests = false;
			}
			
			function onError(e:IOErrorEvent):void
			{
				// There was an error gettting user achievements.
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set flag.
				_loadingAvailableQuests = false;
			}
		}
		
		private static function loadActiveQuests():void
		{
			if (Constants.QUEST_ENABLED == false) return;
			
			// Dispatch an event that signifies that we will begin
			// loading a list of active quests. These can quests that
			// have been completed or quests that have been started but
			// not yet completed.
			_instance.dispatchEvent(new Event(LOAD_ACTIVE_QUESTS));
			
			// If another load is initiated before this load is complete and parsed,
			// then we will not finish loading this load.
			var thisLoadFinished:Boolean = false;
			_instance.addEventListener(LOAD_ACTIVE_QUESTS, onNewLoadInit);
			
			// Query server for active user achievements.
			var avatar:Avatar = ModelLocator.getInstance().avatar;
			var avatarId:int = avatar.avatarId;
			var url:String = 'http://' + Environment.getApplicationDomain() + '/test/quest/listCurrent?avatarId=' + avatarId;
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(request);
			
			function onComplete(e:Event):void
			{
				// Recieved user achievements response.
				// Remove event listeners.
				_instance.removeEventListener(LOAD_ACTIVE_QUESTS, onNewLoadInit);
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set flag.
				thisLoadFinished = true;
				
				// Extract XML.
				var xml:XML = new XML(urlLoader.data);
				var status:int = xml.@status;
				if (status != 1)
				{
					// Invalid response.
				}
				else
				{
					// Recieved valid response.
					// Parse the XML into a collection of achievments.
					_activeUserQuests = AvatarAchievementCollection.ParseMultipleAvatarAchievementsXML(xml.avatarAchievements);
					
					// Parse all active resolve items.
					// These are inventory items that have potential to resolve an achievement.
					parseAllResolveInventoryItems();
					
					// Dispatch an event because the active events have been updated.
					_instance.dispatchEvent(new Event(ACTIVE_QUESTS_UPDATE));
				}
				
				// Log trace.
				trace('QuestManager.loadActiveQuests() - loaded and parsed ' + urlLoader.bytesLoaded + ' bytes.');
				
				// Load available quests.
				loadAvailableQuests();
			}
			
			function onError(e:IOErrorEvent):void
			{
				// There was an error gettting user achievements.
				// Remove event listeners.
				_instance.removeEventListener(LOAD_ACTIVE_QUESTS, onNewLoadInit);
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set flag.
				thisLoadFinished = true;
				
				// If we don't yet have a list of available quests.
				// Get it.
				if (_availableQuests == null) loadAvailableQuests();
			}
			
			function onNewLoadInit(e:Event):void
			{
				// If another load has been initiated and this load has not completed,
				// cancel this load.
				if (thisLoadFinished != true)
				{
					// Cancel this load.
					// Remove event listeners.
					_instance.removeEventListener(LOAD_ACTIVE_QUESTS, onNewLoadInit);
					urlLoader.removeEventListener(Event.COMPLETE, onComplete);
					urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					// Close url loader.
					urlLoader.close();
					// Log trace.
					trace('QuestManager.loadActiveQuests() - load canceled (after ' + urlLoader.bytesLoaded + ' bytes) because a new load was called before this one finished.');
				}
			}
		}
		
		private static function handleAvailableQuests(quests:AchievementCollection):void
		{
			// Make sure there are quests to handle.
			if (quests == null) return;
			
			var i:int = 0;
			var len:int = quests.length;
			for (i; i < len; i++)
			{
				var quest:Achievement = quests.getAt(i);
				
				// Make sure the quest hasn't been delivered already.
				if (isQuestDelivered(quest.id)) continue;
				
				// Make sure it is not an ACTIVE quest.
				if (_activeUserQuests != null && _activeUserQuests.getFromId(quest.id) != null) continue;
				
				// Deliver this quest.
				var deliveryFunction:Function = _questDeliverMethods[quest.deliveryMethod] as Function;
				if (deliveryFunction != null) deliveryFunction(quest);
			}
		}
		
		private static function deliverQuestPDA(quest:Achievement):void
		{
			// Make a PDA phone call.
			var callData:PDACallModel = new PDACallModel();
			var questProvider:QuestProvider = quest.questProviders.getAt(0);
			if (questProvider == null) return;
			callData.callerId = questProvider.id;
			callData.callerName = questProvider.name;2
			callData.callerImageUrl = Environment.getAssetUrl() + '/test/static/quest/questProvider/incoming?questProviderId=' + questProvider.id;
			
			// Listen for when it is answered.
			PDAController.getInstance().addEventListener(PDACallEvent.CALL_ANSWERED, onCallAnswered);
			
			// Send the phone call.
			PDAController.getInstance().newPhoneCall(callData);
			
			// Set flag.
			setIsQuestDelivered(quest.id, true);
			
			function onCallAnswered(e:PDACallEvent):void
			{
				// When the call is answered.
				
				// Remove event listener.
				PDAController.getInstance().removeEventListener(PDACallEvent.CALL_ANSWERED, onCallAnswered);
				
				// Show a quest card.
				showQuestCard(quest);
			}
		}
		
		private static function deliverQuestNPC(quest:Achievement):void
		{
			// Set flag.
			setIsQuestDelivered(quest.id, true);
		}
		
		private static function deliverQuestImmediate(quest:Achievement):void
		{
			// Accept the quest.
			acceptQuest(quest.id);
			
			// Set flag.
			setIsQuestDelivered(quest.id, true);
		}
		
		private static function deliverQuestImmediateCard(quest:Achievement):void
		{
			// Show the quest card.
			showQuestCard(quest);
			
			// Set flag.
			setIsQuestDelivered(quest.id, true);
		}
		
		private static function showQuestCard(quest:Achievement, isLaunchedByUser:Boolean = false):void
		{
			// Show quest card as a pop up.
			var card:QuestCard = new QuestCard(quest);
			card.addEventListener(QuestCardEvent.OK, onCardOk);
			card.init();
			
			// Show the mission card, even though it isn;t completely loaded yet.
			_roomView.addQuedPopUp(card);
			
			// Set flag.
			setIsQuestDelivered(quest.id, true);
			
			function onCardOk(e:QuestCardEvent):void
			{
				// Remove listeners.
				card.removeEventListener(QuestCardEvent.OK, onCardOk);
				
				// Accept the quest.
				acceptQuest(quest.id);
				
				// Hide card.
				var transParams:Object = new Object();
				transParams.duration = 300; // Transition duration.
				_roomView.removeQuedPopUp(card, PopUpTransition.FADE_OUT, transParams);
			}
		}
		
		private static function getAvailableQuestFromProvider(questProvider:QuestProvider):Achievement
		{
			// Return true if the quest provider has an available quest that is not active.
			
			var availableQuest:Achievement;
			if (questProvider != null)
			{
				var i:int = 0;
				var len:int = questProvider.achievements.length;
				for (i; i < len; i++)
				{
					availableQuest = questProvider.achievements.getAt(i);
					if (_activeUserQuests != null && _activeUserQuests.getFromId(availableQuest.id) != null)
					{
						// This quest is already active.
						availableQuest = null;
					}
					else
					{
						// Found an available quest that is not yet active.
						i = len;
					}
				}
			}
			
			if (availableQuest != null)
			{
				return availableQuest;
			}
			else
			{
				return null;
			}
		}
		
		private static function showQuestCutscne(quest:Achievement, isLaunchedByUser:Boolean = false):void
		{
			trace('QuestManager.showQuestCutscne(quest.id=' + quest.id + ', isLaunchedByUser=' + isLaunchedByUser.toString() + ')');
			
			// Build url.
			var url:String = QuestMovieUtil.GetMovieUrl(quest.id);
			
			trace('Will load mission resolve asset: ' + url);
			
			// Mute room sound.
			var iRoomVolume:Number = _roomView.getRoomController().roomSoundVolume;
			if (!_roomView.getRoomController().isMuted)
			{
				_roomView.getRoomController().roomSoundVolume = 0;
			}
			// Create a movie container.
			var movieContainer:MissionResolveMovieContainer = new MissionResolveMovieContainer();
			movieContainer.name = "Loading";
			_roomView.addQuedPopUp(movieContainer);
			
			// Show the cutscene.
			var cutscene:DisplayObject;
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				
				trace('Error loading mission resolve asset: ' + url);
				
				// Turn room volume back to what it initialy was.
				if (!_roomView.getRoomController().isMuted)
				{
					_roomView.getRoomController().roomSoundVolume = iRoomVolume;
				}
			
				// Handle post quest resolve.
				if (isLaunchedByUser != true) handlePostQuestResolve(quest.id);
				
				// Remove cutscene pop up without transition.
				_roomView.removeQuedPopUp(movieContainer);
			}
			
			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				
				trace('Completed loading mission resolve asset: ' + url);
				
				// Get reference to quest resolve movie.
				cutscene = loader.content;
				cutscene.addEventListener(Event.CLOSE, onClose);
				
				// Handle any procedures before we show the resolve movie.
				QuestResolveMovieHandlers.handleResolveMovie(quest.id, cutscene);
				
				// Add the movie to the container.
				movieContainer.movie = cutscene;
				movieContainer.show();
			}
			
			function onClose(e:Event):void
			{
				// Remove listener.
				cutscene.removeEventListener(Event.CLOSE, onClose);
				
				trace('QuestManager.showQuestCutscne().onClose()');
				
				// Turn room volume back to what it initialy was.
				_roomView.getRoomController().roomSoundVolume = iRoomVolume;
				
				// Handle post quest resolve.
				if (isLaunchedByUser != true) handlePostQuestResolve(quest.id);
				
				// Remove cutscene pop up with transition.
				var transParams:Object = new Object();
				transParams.duration = 300; // Transition duration.
				_roomView.removeQuedPopUp(movieContainer, PopUpTransition.FADE_OUT, transParams);
			}
		}
		
		private static function handleTeamSelect():void
		{
			MainUtil.showDialog(TeamSelectDialog);
		}
		
		private static function handlePostQuestResolve(questId:uint):void
		{
			// Determine handler.
			var handler:Function = _postQuestResolveHandlers[questId] as Function;
			
			// Execute handler.
			if (handler != null) handler();
		}
		
		private static function isQuestDelivered(questId:uint):Boolean
		{
			return _questIsDeliveredFlags[questId] as Boolean;
		}
		
		private static function setIsQuestDelivered(questId:uint, isDelivered:Boolean):void
		{
			_questIsDeliveredFlags[questId] = isDelivered;
		}
		
		private static function parseAllResolveInventoryItems():void
		{
			// Parse all active resolve items.
			// These are inventory items that have potential to resolve an achievement.
			
			var activeMissions:AvatarAchievementCollection = _activeUserQuests;
			
			// Loop through the missions.
			var i:int = 0;
			var len:int = activeMissions.length;
			var npcInventoryIds:Array = [];
			var inventoryItemResolveMap:Array = [];
			var inventoryItemResolveMvpLockMap:Array = [];
			var inventoryItemResolveAchievementMap:Array = [];
			for (i; i < len; i++)
			{
				// Get reference to mission.
				var mission:AvatarAchievement = activeMissions.getAt(i);
				// If the mission is complete,
				// then we will disregard the
				// criteria.
				if (mission.isComplete == true) continue;
				
				// Get list of click npc criteria
				// for this mission.
				var clickNpcCriteria:Array = mission.getCriteriaWithAttributeId(int(UserActionTypes.NPC_CLICKED));
				
				// Determine the mission context for this achievement.
				var missionContext:int = mission.getMetricAttributeWithAttributeId(AchievementMetricAttributeType.MISSION_CONTEXT);
				// Determine mvp lock.
				var mvpLock:int = mission.getMetricAttributeWithAttributeId(AchievementMetricAttributeType.MVP_LOCK);
				
				// Add all the attribute values to an array.
				for each (var criteria:AchievementCriteria in clickNpcCriteria)
				{
					// Get iventory item id.
					var iventoryItemId:int = criteria.attributeValue;
					
					// Map inventory item id to mission context value.
					inventoryItemResolveMap[iventoryItemId] = missionContext;
					// Map inventory item id to mvp lock status.
					if (mvpLock > 0) inventoryItemResolveMvpLockMap[iventoryItemId] = mvpLock;
					// Map inventory item to achievement.
					inventoryItemResolveAchievementMap[iventoryItemId] = mission.id;
				}
			}
			
			// Store in instance variable.
			_inventoryItemResolveMap = inventoryItemResolveMap;
			_inventoryItemResolveMvpLockMap = inventoryItemResolveMvpLockMap;
			_inventoryItemResolveAchievementMap = inventoryItemResolveAchievementMap;
		}
		
		private static function getAchievementMvpLockStatusFromInventoryId(inventoryId:int):int
		{
			var mvpLockStatus:int = _inventoryItemResolveMvpLockMap[inventoryId] as int;
			return mvpLockStatus;
		}
		
		private static function getAchievementIdFromInventoryId(inventoryId:int):int
		{
			var achievementId:int = _inventoryItemResolveAchievementMap[inventoryId] as int;
			return achievementId;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public static function get userAchievements():AchievementCollection
		{
			return _availableQuests;
		}
		public static function set userAchievements(value:AchievementCollection):void
		{
			if (value == _availableQuests) return;
			
			_availableQuests = value;
			
			// Handle available quests.
			handleAvailableQuests(_availableQuests);
			
			// Dispatch an event because the available events have been updated.
			_instance.dispatchEvent(new Event(AVAILABLE_QUESTS_UPDATE));
		}
		
		public static function get activeUserQuests():AvatarAchievementCollection
		{
			return _activeUserQuests;
		}
		
		public static function get questProviders():QuestProviderCollection
		{
			return _questProviders;
		}
		
		public static function get roomView():IRoomView
		{
			return _roomView;
		}
		public static function set roomView(value:IRoomView):void
		{
			if (value == _roomView) return;
			
			// Remove listeners from previous room view.
			if (_roomView != null)
			{
				_roomView.removeEventListener(GameLauncherEvent.CLICKED, onGameLaunchClick);
				_roomView.addEventListener(NPCEvent.NPC_CLICK, onNpcClick);
			}
			
			_roomView = value;
			
			// Add room view listeners.
			_roomView.addEventListener(GameLauncherEvent.CLICKED, onGameLaunchClick);
			_roomView.addEventListener(NPCEvent.NPC_CLICK, onNpcClick);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private static function onAchievementComplete(e:SocketRoomEvent):void
		{
			trace('QuestManager.onAchievementComplete()');
			
			// Re-query for active quests.
			loadActiveQuests();
			
			// Parse event data.
			var evParams:Object = e.params;
			var xml:XML = new XML(evParams[evParams.action]);
			var i:uint = 0;
			while (xml.achievements.achievement[i] != null)
			{
				var achievementXml:XML = xml.achievements.achievement[i];
				var id:uint = achievementXml.achievementId;
				
				trace('\tParsing achievement: ' + id.toString());
				
				// Get a reference to the quest in the list of available quests.
				var quest:Achievement = getAvailableQuest(id);
				
				// Try to get a reference from the list of active quests.
				if (quest == null)
				{
					var mission:AvatarAchievement = getActiveQuest(id);
					if (mission.isComplete != true) quest = getActiveQuest(id);
				}
				
				if (quest == null) continue;
				
				trace('\tFound corresponding mission(' + id.toString() + ') on client');
				
				// FLag for whether or not to show cutscene.
				var showCutScene:Boolean = true;
				
				// If it's for one of the scuba pieces,
				// and all of the pieces have now been found.
				// don't show a cutscene.
				var scubaPieceMissionIds:Array = [577, 578, 579, 580, 581];
				var completesScuba:Boolean = completesCollectionMission(id, scubaPieceMissionIds);
				if (completesScuba == true) showCutScene = false;
				
				// If it's for one of the trick or treat pieces,
				// and all of the pieces have now been found.
				// don't show a cutscene.
				var trickOrTreatPieceMissionIds:Array = [610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626, 627, 628, 629];
				var completesTrickOrTreat:Boolean = completesCollectionMission(id, trickOrTreatPieceMissionIds);
				if (completesTrickOrTreat == true) showCutScene = false;
				
				// If all Hats found, don't show cut scene
				var hatPieceMissionIds:Array = [691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,708,709,710,711,712,713,714,715,716,717,718,719,720];
				var completesHatMission:Boolean = completesCollectionMission(id, hatPieceMissionIds);
				if (completesHatMission == true) showCutScene = false;
				
				// Only show a cutscene for this quest if it's not the
				// a collection mission.
				if (quest.hasCutscene == true && showCutScene == true && quest.id != SCUBA_CERTIFICATION_MISSION_ID &&
					quest.id != NBA_SCAVENGER_HUNT_MISSION_ID && quest.id != ZOMBIE_HIDE_AND_SEEK_MISSION_ID && quest.id != TRICK_OR_TREAT_MISSION_ID &&
					quest.id != TURKEY_HIDE_AND_SEEK_MISSION_ID && quest.id != HAT_HIDE_AND_SEEK_MISSION_ID)
				{
					showQuestCutscne(quest);
				}
				
				trace('\tWill tell server that mission(' + id.toString() + ') has been completed');
				
				// Send a Mission Complete user action to the server.
				// It would be ideal if the client did not have to do this.
				// This will potentially complete more missions.
				var socketEvParams:Object = new Object();
				socketEvParams.actionType = UserActionTypes.MISSION_COMPLETE;
				socketEvParams.actionValue = quest.id.toString(); // Completed mission id.
				SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.USER_ACTION, socketEvParams);
				
				i++;
			}
			
			// Dispatch an event to signal quest complete.
			_instance.dispatchEvent(new Event(QUEST_COMPLETE));
		}
		
		private static function onAchievementAccept(e:SocketRoomEvent):void
		{
			// Get params.
			var params:Object = e.params;
			var questId:uint = params.achievementAccepted;
			
			// Determine unique handler for accepting this quest.
			var handler:Function = _questAcceptHandlers[questId] as Function;
			// Execute the handler.
			if (handler != null) handler();
			
			// When quests are accepted.
			// Re-query for active quests.
			loadActiveQuests();
		}
		
		private static function onPDAShowQuestCard(e:QuestCardEvent):void
		{
			showQuestCard(e.quest, true);
		}
		
		private static function onShowQuestMovie(e:QuestMovieEvent):void
		{
			// Play the cutscene.
			showQuestCutscne(e.quest, true);
		}
		
		private static function onGameLaunchClick(e:GameLauncherEvent):void
		{
			// Assume that this is a game launch challenge.
			// Dispatch a socket event.
			// It signifies a that a user is trying to launch a game.
			var params:Object = new Object();
			params.actionType = UserActionTypes.GAME_LAUNCH_CLICKED;
			params.actionValue = e.gameId.toString();
			if (Constants.QUEST_ENABLED == true) SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.USER_ACTION, params);
		}
		
		private static function onNpcClick(e:NPCEvent):void
		{
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			
			// Check if mission is mvp locked
			var mvpLock:int = _inventoryItemResolveMvpLockMap[e.npcId];
			// 0 means no lock
			if (mvpLock != 0)
			{
				// guests need to register
				if (userAvatar.membershipStatus == MembershipStatus.GUEST)
				{
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}
				// free members -- upsell
				else if (userAvatar.membershipStatus == MembershipStatus.MEMBER)
				{
					var achievementId:int = getAchievementIdFromInventoryId(int(e.npcId));
					LoggingUtil.sendClickLogging(LoggingUtil.missionLockViewLinkIdMapping[achievementId]);
					
					var goMvpIdentifier:int = LoggingUtil.missionLockClickLinkIdMapping[achievementId];
					// default upsell
					if (mvpLock == 1)
					{
						var mvpAlert:MVPAlert =	MVPAlert.show("You must be an MVP member to do this mission", "MVP Only", onUpsellClose);
						mvpAlert.addButton("Become A Member", goMvpIdentifier, 250);
					}
					// custom upsell
					else
					{
						CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/81/gameFile/mvp_upsell_" + achievementId + ".swf",
											goMvpIdentifier, onUpsellClose);
					}
					return;
				}
			}
			
			// Add a hard code case for Blake in the football field.
			var blakeNpcId:String = '439';
			if (e.npcId == blakeNpcId)
			{
				// Make sure the user is registered.
				if (userAvatar.membershipStatus == MembershipStatus.GUEST)
				{
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}
			}
			
			// Dispatch a socket event.
			// It signifies a user action of clicking an NPC.
			var params:Object = new Object();
			params.actionType = UserActionTypes.NPC_CLICKED;
			params.actionValue = e.npcId;
			if (Constants.QUEST_ENABLED == true) SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.USER_ACTION, params);
			
			// Execute hard coded click handlers.
			NPCClickHandlers.handleNPCClick(e.npcId, _roomView);
			
			// Add a hard code case for the team select NPC.
			// This is bad, but the quickest way to handle it right now.
			if (e.npcId == TEAM_SELECT_NPC_ID)
			{
				if (userAvatar.membershipStatus == MembershipStatus.GUEST)
				{
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}
				
				// Make sure the team select mission is complete.
				//CHANGE:Anybody Can Do Team Select Now
				//var teamSelectMission:AvatarAchievement = _activeUserQuests.getFromId(TEAM_SELECT_QUEST_ID);
				//if (teamSelectMission == null || teamSelectMission.isComplete != true) return;
				// Show the team selection dialog.
				handleTeamSelect();
			}
			
			function onUpsellClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;
				
				if (identifier == goMvpIdentifier)
					MainUtil.goToMVP(identifier);
			}
		}
		
		private static function onPostIntroResolve():void
		{
			// After the intro quest resolve,
			// Send the user to their home turf.
			
			var user:User = ModelLocator.getInstance().user;
			var roomId:String = 'private_' + user.avatarId + '_1';
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
		}
		
		private static function onRegistrationQuestAccept():void
		{
			// If the local user is already a registered member,
			// complete this quest by dispatching a user action
			// for registration.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus != MembershipStatus.GUEST)
			{
				var params:Object = new Object();
				params.actionType = UserActionTypes.REGISTRATION_COMPLETE;
				params.actionValue = '1';
				SocketClient.getInstance().sendPluginMessage('room_manager', SocketRoomEvent.USER_ACTION, params);
			}
		}
		
		private static function onIntroQuestAccept():void
		{
			//
			// NO LONGER DOES ANYTHING
			// ONLY HERE FOR REFERENCE
			//
			
			// This should be the quest/mission where Blake
			// tells the user to go to their home turf.
			//
			// We'll try to draw attention to the home turf
			// button on the hud.
			//
			// We use the GameConsoleDelegate because it
			// has a static reference to the game console.
			// From there we can apply a highlight on any
			// of the game console buttons.
			// Use statics of GameConsole to get button ids.
			//
			// We'll stop the highlighting when the user enters
			// a new room.
			/*RoomManager.getInstance().addEventListener(RoomManagerEvent.ENTER_ROOM_START, onEnterRoomStart);
			GameConsoleDelegate.gameConsole.startButtonHighlight(GameConsole.HOME_TURF_BUTTON_ID);
			
			function onEnterRoomStart():void
			{
				// Remove listener.
				RoomManager.getInstance().removeEventListener(RoomManagerEvent.ENTER_ROOM_START, onEnterRoomStart);
				
				// Stop highlighting home turf button.
				GameConsoleDelegate.gameConsole.stopButtonHighlight(GameConsole.HOME_TURF_BUTTON_ID);
			}*/
		}
		
		private static function completesCollectionMission(missionId:int, collectionMissionIds:Array):Boolean
		{
			var completesCollection:Boolean = true;
			if (collectionMissionIds.indexOf(missionId) > -1)
			{
				// The mission that was completed is part of the collection.
				for each (var pieceMissionId:int in collectionMissionIds)
				{
					if (pieceMissionId == missionId) continue;
					var pieceMission:AvatarAchievement = getActiveQuest(pieceMissionId);
					if (pieceMission == null || pieceMission.isComplete != true) completesCollection = false;
				}
			}
			else
			{
				completesCollection = false;
			}
			
			return completesCollection;
		}
		
		// RETURNS: 0 if avatar doesn't have achievement, 1 if avatar has achievement and it isn't completed,
		//          2 if achievement is complete
		public static function getAchievementStatus(missionId:int):int
		{
			// Attempt to get active quest
			var q:AvatarAchievement = getActiveQuest(missionId);
			if (q)
			{
				if (q.isComplete)
					return 2;
				else
					return 1;
			}
			
			return 0;	
		}
		
	}
}
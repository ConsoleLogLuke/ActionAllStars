package com.sdg.control.room.itemClasses
{
	import com.sdg.components.dialog.ImageDialog;
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.control.ReferAFriendController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarAchievement;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.npc.NPCEvent;
	import com.sdg.quest.QuestManager;
	import com.sdg.utils.MainUtil;
	
	internal class AbstractItemInteractionHandlers extends Object
	{
		private static var _clickHandlers:Array;
		private static var _isInit:Boolean;
		
		/*
			This would determine if the user is registered. If not, the registration 
			dialog will be triggered. If they are already registred, it will 
			dispatch a user action to the socket server (NPC_CLICKED).
		*/
		public static const TRIGGER_REGISTRATION_AND_DISPATCH_USER_ACTION:String = '100';
		
		// Launch the first puzzle if the puzzle 1 mission is active.
		public static const NFL_PUZZLE_LAUNCH_1:String = '101';
		public static const NFL_PUZZLE_LAUNCH_2:String = '102';
		public static const NFL_PUZZLE_LAUNCH_3:String = '103';
		
		// Dispatch an NPC clicked user action.
		public static const DISPATCH_NPC_CLICKED:String = '104';
		
		// Trigger registration.
		public static const TRIGGER_REGISTRATION:String = '105';
		
		// Launch an external flash game.
		// Determine gamne id based on inventory attributes.
		public static const LAUNCH_GAME:String = '106';
		
		// Launchg external flash game BUT make sure they have accepted a specific mission(achievement).
		// Get game id & mission(achievement) id from inventory attributes.
		public static const LAUNCH_GAME_WITH_ACHIEVEMENT_RESTRICTION:String = '107';
		
		// Similar to 107, except show a screen if the player doesn't have a mission 
		public static const LAUNCH_COMBO_LOCK:String = '108';
		
		// Specific for September
		public static const SHOW_OLD_MINIMAZE_MISSION_START:String = '109';
		public static const SHOW_OLD_MINIMAZE_MISSION_END:String = '110';
		
		// Refer A Friend Related
		public static const LAUNCH_REFER_A_FRIEND:String = '111';
		
		// Ticker zoom in related
		public static const SHOW_TICKER_IMAGE:String = '112';
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public static function handleClick(itemController:IRoomItemController, clickHandlerId:String):void
		{
			// Make sure initialization has taken place.
			init();
			
			// Get a reference to the click handler.
			var clickHandler:Function = _clickHandlers[clickHandlerId] as Function;
			if (clickHandler != null) clickHandler(itemController);
		}
		
		////////////////////
		// PRIVATE METHODS
		////////////////////
		
		private static function init():void
		{
			// Make sure init is only called once.
			if (_isInit == true) return;
			
			// Define click handlers.
			_clickHandlers = [];
			_clickHandlers[TRIGGER_REGISTRATION_AND_DISPATCH_USER_ACTION] = triggerRegistrationAndDispatchUserAction;
			_clickHandlers[NFL_PUZZLE_LAUNCH_1] = nflPuzzleLaunch1;
			_clickHandlers[NFL_PUZZLE_LAUNCH_2] = nflPuzzleLaunch2;
			_clickHandlers[NFL_PUZZLE_LAUNCH_3] = nflPuzzleLaunch3;
			_clickHandlers[DISPATCH_NPC_CLICKED] = dispatchNpcClicked;
			_clickHandlers[TRIGGER_REGISTRATION] = triggerRegistration;
			_clickHandlers[LAUNCH_GAME] = launchGame;
			_clickHandlers[LAUNCH_GAME_WITH_ACHIEVEMENT_RESTRICTION] = launchGameWithAchievementRestriction;
			_clickHandlers[LAUNCH_COMBO_LOCK] = launchComboLock;
			
			_clickHandlers[SHOW_OLD_MINIMAZE_MISSION_START] = showOldMissionStart;
			_clickHandlers[SHOW_OLD_MINIMAZE_MISSION_END] = showOldMissionEnd;
			_clickHandlers[LAUNCH_REFER_A_FRIEND] = showReferAFriend;
			_clickHandlers[SHOW_TICKER_IMAGE] = showTickerInfo;
		
			// Set flag.
			_isInit = true;
		}
		
		////////////////////
		// HANDLERS
		////////////////////

		private static function triggerRegistrationAndDispatchUserAction(itemController:IRoomItemController):void
		{
			// Make sure the user is registered.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			else
			{
				// If the user is registered, dispatch a user action.
				itemController.display.dispatchEvent(new NPCEvent(NPCEvent.NPC_CLICK, itemController.item.id.toString(), true));
			}
		}
		
		private static function nflPuzzleLaunch1(itemController:IRoomItemController):void
		{
			// If the first puzzle mission is active, but not complete
			// launch the first puzzle game.
			var puzzleMission1:AvatarAchievement = QuestManager.getActiveQuest(QuestManager.NFL_PUZZLE_1_QUEST_ID);
			if (puzzleMission1 != null && puzzleMission1.isComplete != true)
			{
				// Launch the puzzle game.
				var gameId:int = 53;
				RoomManager.getInstance().loadGame(gameId);
			}
		}
		
		private static function nflPuzzleLaunch2(itemController:IRoomItemController):void
		{
			// If the second puzzle mission is active, but not complete
			// launch the second puzzle game.
			var puzzleMission2:AvatarAchievement = QuestManager.getActiveQuest(QuestManager.NFL_PUZZLE_2_QUEST_ID);
			if (puzzleMission2 != null && puzzleMission2.isComplete != true)
			{
				// Launch the puzzle game.
				var gameId:int = 54;
				RoomManager.getInstance().loadGame(gameId);
			}
		}
		
		private static function nflPuzzleLaunch3(itemController:IRoomItemController):void
		{
			// If the third puzzle mission is active, but not complete
			// launch the third puzzle game.
			var puzzleMission3:AvatarAchievement = QuestManager.getActiveQuest(QuestManager.NFL_PUZZLE_3_QUEST_ID);
			if (puzzleMission3 != null && puzzleMission3.isComplete != true)
			{
				// Launch the puzzle game.
				var gameId:int = 55;
				RoomManager.getInstance().loadGame(gameId);
			}
		}
		
		private static function dispatchNpcClicked(itemController:IRoomItemController):void
		{
			itemController.display.dispatchEvent(new NPCEvent(NPCEvent.NPC_CLICK, itemController.item.id.toString(), true));
		}
		
		private static function triggerRegistration(itemController:IRoomItemController):void
		{
			// Make sure the user is registered.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
		}
		
		private static function launchGame(itemController:IRoomItemController):void
		{
			// Determine game id from inventory attributes.
			var gameId:int = itemController.item.attributes.gameId;
			if (gameId < 1) return;
			
			// Launch external flash game.
			RoomManager.getInstance().loadGame(gameId);
		}
		
		private static function launchGameWithAchievementRestriction(itemController:IRoomItemController):void
		{
			// Make sure the user has accepted a specific mission.
			// Extract the mission id from the "isGroup" attribute.
			var missionId:int = itemController.item.attributes['isGroup'] as int;
			if (missionId < 1) return;
			var mission:AvatarAchievement = QuestManager.getActiveQuest(missionId);
			if (mission == null) return;
			
			// It appears that the user has accepted the mission.
			// Now launch an external flash game.
			launchGame(itemController);
		}
		
		private static function launchComboLock(itemController:IRoomItemController):void
		{
			// Make sure they have accepted the mission to go see Lebron.
			// They should have accepted this after finding all 6 note pieces
			// in the scavenger maze.
			var missionId:int = 592;
			var mission:AvatarAchievement = QuestManager.getActiveQuest(missionId);
			if (mission == null)
			{
				//Show Dialog
				MainUtil.showDialog(InteractiveDialog,{url:Environment.getAssetUrl()+"/test/gameSwf/gameId/75/gameFile/not_ready_combo_lock.swf",id:"Combo Lock Not Ready"}, false, false);
				return;
			}
			
			// It appears that the user has accepted the mission.
			// Now launch an external flash game.
			launchGame(itemController);
		}
		
		//TODO: should really have an KVP attribute to get asset names.
		private static function showOldMissionStart(itemController:IRoomItemController):void
		{
			MainUtil.showDialog(InteractiveDialog,
								{itemId:6094,
								url:Environment.getAssetUrl()+"/test/swfDoodad/layer?layerId=1&itemId=6094",
								id:"Wade start mission"}, 
								false, false);
		}
		private static function showOldMissionEnd(itemController:IRoomItemController):void
		{
			MainUtil.showDialog(InteractiveDialog,
								{itemId:6095,
								url:Environment.getAssetUrl()+"/test/swfDoodad/layer?layerId=1&itemId=6095",
								id:"Jermaine end fake mission"}, 
								false, false);
		}
		
		private static function showReferAFriend(itemController:IRoomItemController):void
		{
			// Get Source Item Id
			var userInvId:uint = itemController.item.id;
			
			// Get Avatar
			var av:Avatar = ModelLocator.getInstance().avatar;
			
			// Launch Refer A Friend
			var referControl:ReferAFriendController = new ReferAFriendController();
			referControl.refer(av,userInvId);
			return;
		}
		
		private static function showTickerInfo(itemController:IRoomItemController):void
		{
			if(itemController.item.display.content.hasOwnProperty("getMouseClickedInfo"))
			{
				var swf:Object = itemController.item.display.content;
				var obj:Object = swf.getMouseClickedInfo();
				if(obj != null)
				{
					MainUtil.showDialog(ImageDialog,
								{info:obj,
								id:"Show URL"}, 
								false, false);
				}
			}
		}
		
	}
}
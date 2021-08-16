package com.sdg.control.room.itemClasses
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.adobe.utils.StringUtil;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.games.Concentration;
	import com.sdg.components.games.InvitePanel;
	import com.sdg.control.HudController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.display.AvatarSprite;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.events.BoardGameActionEvent;
	import com.sdg.events.HudEvent;
	import com.sdg.events.InventoryAttributeSaveEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.TriggerTileEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.Jab;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Reward;
	import com.sdg.model.SdgItem;
	import com.sdg.net.Environment;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	import com.sdg.utils.PreviewUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.core.Application;
	import mx.events.PropertyChangeEvent;
	
	public class AvatarController extends Character
	{
		private var _avatar:Avatar;
		private var _levelChangeHandlerWatcher:ChangeWatcher = null;
		private var _enableTileTriggers:Boolean = true;
		private var _startGameParams:Object;
		private var _statusIdChangeWatcher:ChangeWatcher;
		private var _currentRewardsChangeWatcher:ChangeWatcher;
		
		public var inviteModeOn:Boolean = false;
		
		[Bindable]
		public var invitePanelOn:Boolean = false;
		
		[Bindable]
		public var speedShoesOn:Boolean = false;

		private var _speedItemTypesEquipped:Array = new Array();

		
		public function AvatarController()
		{
			setActionListener("statusUpdate", statusUpdateActionHandler);
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		override public function initialize(item:SdgItem):void
		{
			super.initialize(item);
			
			_avatar = Avatar(item);
			
			if (_avatar.isUserItem)
			{
				// Bind to statusId.
				_statusIdChangeWatcher = BindingUtils.bindSetter(statusChanged, _avatar, "statusId");
				
				// Bind to currentRewards to show reward effects.
				_currentRewardsChangeWatcher = ChangeWatcher.watch(_avatar, "currentRewards", rewardsChangedHandler);
				
				// Add listener for trigger tile events.
				entity.addEventListener(TriggerTileEvent.TILE_TRIGGER, tileTriggerHandler);
				
				// listen for apparel change events
				_avatar.addEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onApparelChanged);

				// listen for apparel list events if we don't already have apparel
				if (_avatar.hasApparel())
					applyInitialApparelEffects();
				else	
					CairngormEventDispatcher.getInstance().addEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);
					
				setActionListener("jab", jabActionHandler);
				setActionListener("startBoardGame", startBoardGameHandler);
				setActionListener("acceptInvite", acceptInviteActionHandler);
				setActionListener("updateInvitePanels", updateInvitePanelsActionHandler);
				setActionListener("boardGameAction", boardGameActionHandler);
			}
			else
			{
				// Bind to level to show level up effect.
				_levelChangeHandlerWatcher = ChangeWatcher.watch(_avatar, "level", levelChangeHandler);
			}
		}
		
		
		
		override public function destroy():void
		{
			// Remove all change watchers.
			if (_levelChangeHandlerWatcher != null)
			{	
				 _levelChangeHandlerWatcher.unwatch();
				 _levelChangeHandlerWatcher = null;
			}
			
			if (item.isUserItem)
			{
				removeActionListener("jab");
				removeActionListener("startBoardGame");
				removeActionListener("acceptInvite");
				removeActionListener("updateInvitePanels");
				removeActionListener("boardGameAction");
				
				// Clean up change watchers.
				_statusIdChangeWatcher.unwatch();
				_statusIdChangeWatcher = null;
				_currentRewardsChangeWatcher.unwatch();
				_currentRewardsChangeWatcher = null;
				
				// Remove listeners.
				entity.removeEventListener(TriggerTileEvent.TILE_TRIGGER, tileTriggerHandler);
				_avatar.removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onApparelChanged);
			}
			
			removeActionListener("statusUpdate");
			
			_startGameParams = null;
			_avatar = null;
			
			super.destroy();
		}
		
		public function goToRoom(room:String):void
		{
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, room));
		}
		
		public function jab(avatarId:int, receiverName:String, jabId:int, gameName:String = "a game", gameSessionId:String = "0", gameId:int = 0):void
		{
		    var sender:Avatar = ModelLocator.getInstance().avatar;
			commitAction("jab", {toAvatarId:avatarId, 
								 jabId:jabId, 
								 senderAvatarId:sender.avatarId, 
								 senderName:sender.name, 
								 receiverName:receiverName, 
								 gameName:gameName,
								 gameId:gameId, 
								 gameSessionId:gameSessionId});

			var jab:Jab = ModelLocator.getInstance().jabMap[jabId];
			if (!jab)
				return;

			// Only show the HUD if not showing an emote
			if(!jab.showEmote)
			{
				// setup the text to be displayed
				var hudText:String = Jab.getMessage(jab.senderText, sender.name, receiverName, gameName);
				HudController.getInstance().addNewJab(jab.jabHudUrl, jab.jabId, receiverName, sender.name, int(sender.avatarId), hudText, true, false, gameSessionId, gameId);
			}
		}
		
		public function inviteAvatarToHomeTurf(avatarIdToBeInvited:int, avatarNameToBeInvited:String):void
		{
			var inviteJabId:int = 4;
			jab(avatarIdToBeInvited, avatarNameToBeInvited, inviteJabId);
		}
		
		public function showInvitePanel(game:Object, gameId:int, avatarIds:Array = null, level:String = null, gameSessionId:String = null):void
		{
		    // makes sure the invite panel is not already on
		    if (invitePanelOn)
		    	return;

		    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
		    invitePanel.init(game, avatarIds, gameId, level, gameSessionId);
		    invitePanelOn = true;
		    inviteModeOn = invitePanel.isMasterPanel;
		}
		
		public function addAvatarToInvitePanel(avatar:Avatar, avatarId:int = 0):void
		{
		    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
		    
		    // if we have no avatar, add the avatar by the avatar id
			if (avatar == null)
				invitePanel.addPlayerByAvatarId(avatarId);
			else	
				invitePanel.addPlayer(avatar);			
		}
		
		public function isAvatarInInvitePanel(avatarId:int):Boolean
		{
		    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
			return invitePanel.hasPlayer(avatarId);
		}
		
		public function sendInvite(avatar:Avatar):void
		{
			// get the invite panel
		    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
		    
		    // what game are we playing?
		    var gameName:String = invitePanel.game.name;
		    
		    jab(avatar.avatarId, avatar.name, 100, gameName, invitePanel.gameSessionId, invitePanel.gameId);
		}
		
		public function startBoardGame(gameId:int, gameSessionId:String, gameName:String, avatarIds:String, gameAttributes:String, level:String):void
		{
		    inviteModeOn = false;			
			commitAction('startBoardGame', { gameId:gameId, gameSessionId:gameSessionId, gameName:gameName, avatarIds:avatarIds, gameAttributes:gameAttributes, level:level });
		} 
		
		public function boardGameAction(gameId:int, gameSessionId:String, level:String, receiverAvatarIds:Array, senderAvatarId:int, actionName:String, actionValue:String):void
		{
			var isPlayingAttribute:Object = null;
			
			if (actionName == "leaveGame" && senderAvatarId == ModelLocator.getInstance().avatar.avatarId)
			{
				ModelLocator.getInstance().currentGameId = 0;
				ModelLocator.getInstance().currentGameSessionId = "";
				ModelLocator.getInstance().currentGameLevel = "";
				
				// remove our 'playing game' emote icon
				isPlayingAttribute = { isPlaying:false };
				emote("removePersistantEmote"); 
			}
			
			commitAction('boardGameAction', { gameId:gameId, gameSessionId:gameSessionId, level:level, receiverAvatarIds:receiverAvatarIds.join(','), senderAvatarId:senderAvatarId, actionName:actionName, actionValue:actionValue }, isPlayingAttribute);
		}
		
		public function acceptInvite(invitedAvatarId:int, inviterAvatarId:int, gameSessionId:String, gameId:int):void
		{
			// make sure the invite panel is not already on - and that a game is not in progress
			if (invitePanelOn)
				return;
				
			commitAction('acceptInvite', { invitedAvatarId:invitedAvatarId, inviterAvatarId:inviterAvatarId, gameSessionId:gameSessionId, gameId:gameId });
		}
		
		public function updateInvitePanels(gameName:String, avatarIds:Array, level:String, gameSessionId:String, gameId:int):void
		{
			commitAction('updateInvitePanels', { gameName:gameName, avatarIds:avatarIds.join(','), level:level, gameSessionId:gameSessionId, gameId:gameId });
		}
		
		public function applyItemEffects(item:InventoryItem, addEffect:Boolean):void
		{
			// walk speed
			if (item.walkSpeedPercent)
			{
				// if this is a use item, make sure the 'use button' has been push and is in effect
				if (item.charges != -1)
				{ 
					var speedShoesButton:Object = Object(Application.application.mainLoader.child.speedShoesBtn.content);
					if (speedShoesButton.effectOn == false)
						return;
				}
				
				var percentToAdd:Number = (item.walkSpeedPercent / 100) - 1;
				
				if (addEffect) 
					walkSpeedMultiplier += percentToAdd;
				else						
					walkSpeedMultiplier -= percentToAdd;
			}
		}
		
		public function setItemCharges(item:InventoryItem, cost:int = 0):void
		{ 
		    dispatchEvent(new InventoryAttributeSaveEvent(_avatar.avatarId, item.inventoryItemId, 1014, item.charges.toString(), cost));			
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		protected function statusChanged(statusId:uint):void
		{
			//dispatchAction("statusUpdate", { statusId:statusId }, { statusId:statusId });
		}
		
		protected function showRewardEffect(rewards:Array):void
		{
			AvatarSprite(display).showRewardEffect(rewards, item);
		}
		
//		protected function showComboRewardEffect(reward1:Reward,reward2:Reward):void
//		{
//			AvatarSprite(display).showComboRewardEffect(reward1,reward2,item);
//		}
		
		override protected function initializeDisplay():void
		{
			super.initializeDisplay();
			
			// Add floor marker to local avatar.
			// Add shadow to all others.
			if (ModelLocator.getInstance().avatar.id == _item.avatarId)
			{
				var blurAmount:int = 4;
				var width:Number = 40;
				var height:Number = 16;
				var localAvatarMarker:Sprite = new Sprite();
				localAvatarMarker.graphics.beginFill(0xffd800);
				localAvatarMarker.graphics.drawEllipse(-width / 2, - height / 2, width, height);
				localAvatarMarker.filters = [new BlurFilter(blurAmount, blurAmount, 1)];
				// This would help with performace but I'm commenting out because Dan (qa guy) gets IE crash when rolling over avatars.
				//localAvatarMarker.cacheAsBitmap = true;
				_display.floorMarker = localAvatarMarker;
			}
			else
			{
				var shadowW:Number = 36;
				var shadowH:Number = 16;
				var shadow:Sprite = new Sprite();
				shadow.graphics.beginFill(0, 0.3);
				shadow.graphics.drawEllipse(-shadowW / 2, - shadowH / 2, shadowW, shadowH);
				// This would help with performace but I'm commenting out because Dan (qa guy) gets IE crash when rolling over avatars.
				//shadow.cacheAsBitmap = true;
				_display.floorMarker = shadow;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get enableTileTriggers():Boolean
		{
			return _enableTileTriggers;
		}
		
		public function set enableTileTriggers(value:Boolean):void
		{
			_enableTileTriggers = value;
		}
		
		public function get avatar():Avatar
		{
			return _avatar;
		}
		
		////////////////////
		// ACTION HANDLERS
		////////////////////
		
		protected function statusUpdateActionHandler(params:Object):void
		{
			
		}
		
		override protected function chatActionHandler(params:Object):void
		{
			super.chatActionHandler(params);
			if (!StringUtil.beginsWith(params.text, "/emote "))
			{
				CairngormEventDispatcher.getInstance().dispatchEvent(new HudEvent(HudEvent.CHAT_MESSAGE, {avatar:_avatar.name, message:params.text}));
			}
		}
		
		protected function jabActionHandler(params:Object):void
		{
			var avatarController:AvatarController = AvatarController(this);
			var jab:Jab = ModelLocator.getInstance().jabMap[params.jabId] as Jab;
			if (!jab) return;

			// is this avatar being ignored?
			if (ModelLocator.getInstance().ignoredAvatars[int(params.senderAvatarId)])
				return;
				
			// setup the text to be displayed
			var senderName:String = String(params.senderName);
			var receiverName:String = String(params.receiverName);	
			var gameName:String = String(params.gameName);	
			var hudText:String = Jab.getMessage(jab.receiverText, senderName, receiverName, gameName);
				
			// show the jab as an emote	
			if (jab.showEmote)
			{
				var emoteText:String = Jab.getMessage(jab.emoteText, senderName, receiverName); 
				RoomManager.getInstance().userController.emote(Environment.getApplicationUrl() + jab.jabEmoteUrl, null, false, 150, 80, false, {text:emoteText});
			}
			else
			{
				HudController.getInstance().addNewJab(jab.jabHudUrl, jab.jabId, receiverName, senderName, int(params.senderAvatarId), hudText, true, false, params.gameSessionId, params.gameId);			
			}
		}
		
		protected function startBoardGameHandler(params:Object):void
		{
			// just return if we are not one of the avatars playing the game
			var isPlaying:Boolean = false;
			var avatarIds:Array = String(params.avatarIds).split(',');
			for each (var avatarId:int in avatarIds)
				if (avatarId == _avatar.avatarId) 
					isPlaying = true;
			
			// are we a player in this game?
			if (!isPlaying)
				return;
			
			// get the invite panel
		    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
		    if (invitePanel.gameSessionId != params.gameSessionId)
		    	return;
		    	
		    if (invitePanel.playerAvatarIds.join(',') == params.avatarIds)
		    {
		    	startBoardGameLocal(params);
		    }
		    else
		    {
		    	_startGameParams = params;
		    	invitePanel.playerAvatarIds = String(params.avatarIds).split(',');
		    	invitePanel.addEventListener(Event.COMPLETE, onStartGameReady);
		    }
		}
		
		protected function startBoardGameLocal(params:Object):void
		{
		    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
		    
			var gameId:int = params.gameId;
			switch (gameId)
			{
				case 1:
					MainUtil.showModalDialog(Concentration, { gameSessionId:params.gameSessionId, gameAttributes:params.gameAttributes, playerPortraits:invitePanel.players.getChildren(), avatarIds:params.avatarIds });
			    	break;
			    default:
			    	break;	 
			}

			// show the 'playing game' emote so others in the room know what we're doing
			emote("assets/swfs/playingGameEmote.swf", null, false, 35, 35, true, null, true);
			
			// let the server know we are now in a game
			commitAction('startingBoardGame', { gameId:params.gameId, gameSessionId:params.gameSessionId, gameName:params.gameName, avatarIds:params.avatarIds, gameAttributes:params.gameAttributes, level:params.level }, { isPlaying:true });
			
			// turn off the invite panel
			invitePanel.close();
			
			// store current game values
			ModelLocator.getInstance().currentGameSessionId = params.gameSessionId;
			ModelLocator.getInstance().currentGameId = params.gameId;
			ModelLocator.getInstance().currentGameLevel = params.level;
		}
		
		protected function onStartGameReady(event:Event):void
		{
		    var invitePanel:InvitePanel = InvitePanel(Application.application.mainLoader.child.invitePanel);
	    	invitePanel.removeEventListener(Event.COMPLETE, onStartGameReady);
			startBoardGameLocal(_startGameParams);
		}
		
		protected function boardGameActionHandler(params:Object):void
		{
			// dispatch the board game action
			var receiverAvatarIdsString:String = params.receiverAvatarIds; 
			var receiverAvatarIds:Array = receiverAvatarIdsString.split(',');
			CairngormEventDispatcher.getInstance().dispatchEvent(new BoardGameActionEvent(params.gameSessionId, params.senderAvatarId, receiverAvatarIds, params.actionName, params.actionValue));
		}

		protected function acceptInviteActionHandler(params:Object):void
		{
			// make sure we are in invite mode
			if (!inviteModeOn)
				return;
			
			// get the invite panel
		    var invitePanel:InvitePanel = Application.application.mainLoader.child.invitePanel as InvitePanel;
		    if (!invitePanel)
		    	return;
		    	
		    // is the the right invite panel?
		    if (invitePanel.gameSessionId != params.gameSessionId)
		    	return;	
		    	
		    // is this avatar already in our list?	
		    if (invitePanel.hasPlayer(params.invitedAvatarId))
		    	return;
		    	
		    // is a game already in progress?
		    if (ModelLocator.getInstance().currentGameId)
		    	return;	
		    	
		    // add the player	
		    invitePanel.addPlayerByAvatarId(params.invitedAvatarId);
		    
		    // let the other players know who's playing
		    updateInvitePanels(invitePanel.game.name, invitePanel.playerAvatarIds, invitePanel.levels.selectedLabel, invitePanel.gameSessionId, params.gameId);
		}
		
		protected function updateInvitePanelsActionHandler(params:Object):void
		{
		    var invitePanel:InvitePanel = Application.application.mainLoader.child.invitePanel as InvitePanel;
		    if (!invitePanel)
		    	return;
		    	
		    // are we in the list of avatarIds for this panel	
		    var avatarIds:Array = String(params.avatarIds).split(',');
		    var isInPanel:Boolean = false;
		    for each (var id:int in avatarIds)
		    	if (id == _avatar.avatarId)
		    		isInPanel = true;
		    		
		    if (!isInPanel && invitePanel.gameSessionId != params.gameSessionId)
		    	return;		
		    	
		    if (!invitePanelOn)
		    	showInvitePanel(params.gameName, params.gameId, avatarIds, params.level, params.gameSessionId);
		    else if (avatarIds.length && params.avatarIds != "0")
		    	invitePanel.playerAvatarIds = avatarIds;	
		    else
		    	invitePanel.close();	
		}
		
		protected function applyInitialApparelEffects():void
		{
			if (!_avatar.isUserItem)
				return;
				
			// add item effects if needed
			for each (var item:Object in _avatar.apparel)
			{
				var inventoryItem:InventoryItem = item as InventoryItem;
				if (inventoryItem)
				{
					if (inventoryItem.isUseItem)
						showUseButton(inventoryItem);
					else	
						applyItemEffects(inventoryItem, true);
				}
			}	
		}
		
		protected function showUseButton(item:InventoryItem):void
		{
			// the buttons in room module bind to these properties (speeedShowsOn, etc) 
			if (item.walkSpeedPercent){
				addSpeedItemType(item.itemTypeId);  //do this before speedShoesOn -- damn bindables...
				speedShoesOn = true;
			}
		}
		
		protected function hideUseButton(item:InventoryItem, removedItem:InventoryItem):void
		{
			// the buttons in room module bind to these properties (speeedShowsOn, etc)  
			if (item.walkSpeedPercent)
			{
				if(removedItem != null)
				{
					this.removeSpeedItemType(removedItem.itemTypeId);
				}
				speedShoesOn = false;
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function levelChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.oldValue != 0 && event.newValue > event.oldValue)
			{
				var reward:Reward = new Reward();
				reward.rewardTypeId = Reward.LEVEL_UP;
				reward.rewardValueTotal = uint(event.newValue);
				showRewardEffect([reward]);
			}
		}
		
		protected function rewardsChangedHandler(event:PropertyChangeEvent):void
		{
			var rewards:Array = event.newValue as Array;
			
			if (rewards == null) return;
			
			showRewardEffect(rewards);

//			//if (rewards) showRewardEffect(rewards[rewards.length - 1]);
//			if (rewards)
//			{
//				if (rewards.length == 1)
//				{
//					showRewardEffect(rewards[0]);
//					return;
//				}
//				
//				var currencyReward:Reward = null;
//				var xpReward:Reward = null;
//				
//				for each (var r:Reward in rewards)
//				{
//					if (r.rewardTypeId == Reward.CURRENCY)
//						currencyReward = r;
//						
//					if (r.rewardTypeId == Reward.EXPERIENCE)
//						xpReward = r;
//				}
//				
//				if (xpReward && currencyReward)
//				{
//					showComboRewardEffect(currencyReward,xpReward);
//				}
//				
//				if (xpReward)
//				{
//					showRewardEffect(xpReward);
//				}
//				else if (currencyReward)
//				{
//					showRewardEffect(currencyReward);
//				}
//			}
		}
		
		protected function tileTriggerHandler(event:TriggerTileEvent):void
		{
			var params:Object = event.params;
			var eventName:String = String(event.params.eventName);
			
			if (!enableTileTriggers)
				return;
				
			// Look for exit trigger tile events.
			if (eventName != "exit") return;
			
			// Get room id.
			var roomId:String = params.destination;
			
			// in the event of "home turf" go to your home turf
			if(roomId == Constants.ROOM_ID_HOME_TURF_LEGACY)
			{
				roomId = 'private_' + _avatar.avatarId + '_1';
				// Guests aren't allowed.
				if (_avatar.membershipStatus == MembershipStatus.GUEST)
				{
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}
			}
			
			// Dispatch event to change rooms.
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
		}
		
		protected function onApparelListCompleted(event:AvatarApparelEvent):void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);
			applyInitialApparelEffects();
		}
		
		protected function onApparelChanged(event:AvatarApparelEvent):void
		{
			// remove any necessary attribute effects
			// the old item is no longer considered on the user.
			// so the only reference to it is via oldItem.
			if (event.oldItem)
			{
				if (event.oldItem.isUseItem)
				{
					// if an item is just removed. Then new item is null.
					if(event.newItem != null)
					{
						hideUseButton(event.oldItem, event.newItem);
					}
					else
					{
						hideUseButton(event.oldItem, event.oldItem);
					}
				}
				applyItemEffects(event.oldItem, false);
			}
			// this code hides the previous 
			// annoyingly because of the way binding works the charges icon won't update
			// if the icon was showing before and you just want to update to a new charge.
			// For example if you were wearing the speed shoes already and put a car suit over it the old values were still showing.
			// so this code force hides the icon in order to reshow it again later.
			// but if you do this without checking specifically for a suit and instead for the same item, theres some sort of
			// race condition that is occuring between the bindable visible and the applyEffects. 
			// The point is if touching this code, carefully test between "speed items" although this SHOULD work
			// with future types as well. Also bindables suck, use events. - -Molly
			if (event.newItem)
			{
				if (event.newItem.isUseItem && event.newItem.itemTypeId == PreviewUtil.SUITS)
				{
					for each (var apparel:InventoryItem in _avatar.apparel)
					{
						if(apparel)
						{
							if(apparel.isUseItem)
							{
								hideUseButton(apparel, event.newItem);
								applyItemEffects(apparel, false);
							}
						}
					}
				}
			}

			// add any necessary attribute effects
			if (event.newItem)
			{
				// if this needs a button the be used just show the button, otherwise apply the item effects now
				if (event.newItem.isUseItem)
					showUseButton(event.newItem);
					
				applyItemEffects(event.newItem, true);
			}
			
			// special case check needed!
			// if the unequipped item is a suit, we need to check to show the old
			// speed shoes charge indicator.
			if (event.oldItem)
			{
				if (event.oldItem.isUseItem && 
					event.oldItem.itemTypeId == PreviewUtil.SUITS)
				{
					for each (var apparel2:InventoryItem in _avatar.apparel)
					{
						if(apparel2)
						{
							if(apparel2.isUseItem)
							{
								showUseButton(apparel2);
								applyItemEffects(apparel2, false);
							}
						}
					}
				}
			}
		}
		
		// they can now equip multiple types of speed items
		// namely the car suits and speed shoes.
		public function addSpeedItemType(addedSpeedItemType:int):void
		{
			// Don't readd things in the event they've been added before
			// this happens when a suit is removed and the speed shoes are also
			// equipped
			for(var i:int = 0; i < _speedItemTypesEquipped.length; ++i)
			{
				if(_speedItemTypesEquipped[i] == addedSpeedItemType)
				{
					return;
				}
			}
			_speedItemTypesEquipped.push(addedSpeedItemType);
		}
		public function removeSpeedItemType(removeSpeedItemType:int):void
		{
			for(var i:int = 0; i < _speedItemTypesEquipped.length; ++i)
			{
				if(_speedItemTypesEquipped[i] == removeSpeedItemType)
				{
					_speedItemTypesEquipped.splice(i,1);
					return;
				}
			}
		}
		// This is so that when the button appears the one on top
		// is always the largest charge
		// returns the item typeID
		public function getEquppedSpeedItemTypeWithHighestCharge():int
		{
			var highestCharge:int = 0;
			var highestTypeId:int = 0;
			// Loop through and find the highest z order
			for(var i:int = 0; i < _speedItemTypesEquipped.length; ++i)
			{
				var currItemTypeId:int = _speedItemTypesEquipped[i];
				var item:InventoryItem = ModelLocator.getInstance().avatar.apparel[
											PreviewUtil.getLayerId(currItemTypeId)] as InventoryItem;
				if(item.charges > highestCharge)
				{
					highestTypeId = currItemTypeId;
					highestCharge = item.charges;
				}
			}
			return highestTypeId;
		}
	}
}

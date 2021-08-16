package com.sdg.control.room
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.sdg.audio.EmbeddedAudio;
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.controls.GameConsoleDelegate;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.control.AASModuleLoader;
	import com.sdg.control.BuddyManager;
	import com.sdg.control.PDAController;
	import com.sdg.control.ReferAFriendController;
	import com.sdg.control.room.itemClasses.*;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.render.RenderLayer;
	import com.sdg.events.GameLauncherEvent;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.events.RoomItemEvent;
	import com.sdg.events.RoomManagerEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.room.item.RoomItemCircleMenuEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ItemType;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.PetItem;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItem;
	import com.sdg.model.SdgItemClassId;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.pet.PetManager;
	import com.sdg.pet.card.IntegratedPetInfoPanel;
	import com.sdg.sim.entity.IMapOccupant;
	import com.sdg.sim.map.*;
	import com.sdg.store.StoreConstants;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.avatar.AvatarCircleMenu;
	import com.sdg.view.avatar.LocalAvatarCircleMenu;
	import com.sdg.view.avatarcard.IntegratedAvatarInfoPanel;
	import com.sdg.view.cursor.ArrowCursor;
	import com.sdg.view.room.PetCircleMenu;
	import com.sdg.view.room.RoomItemCircleMenu;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import mx.events.CloseEvent;
	
	public class RoomUIController extends RoomControllerBase
	{
		private static const _SELECTED_ITEM_GLOW:GlowFilter = new GlowFilter(0xffffff, 1, 4, 4, 4);
		
		protected var _arrowCursor:ArrowCursor;
		protected var _mouseItemController:IRoomItemController;
		protected var _mouseOverUiLayer:Boolean;
		protected var _keyboardInputController:RoomKeyboardController;
		protected var _animMan:AnimationManager;
		protected var _avatarInspectEnabled:Boolean;
		protected var _shopEnabled:Boolean;
		protected var _printInviteEnabled:Boolean;
		protected var _useItemRollOverLabel:Boolean;
		protected var _allowKeyboardWalking:Boolean;
			
		private var _selectedRoomItemController:IRoomItemController;
		private var _currentCircleMenu:RoomItemCircleMenu;
		private var _previousSelectedRoomItemController:IRoomItemController;
		private var _previousCircleMenu:RoomItemCircleMenu;
		private var _walkSound:Sound;
		
		public function RoomUIController()
		{
			super();
			_arrowCursor = new ArrowCursor(30, 22, 0xffc05c, 0x000000);
			_arrowCursor.mouseEnabled = false;
			_arrowCursor.mouseChildren = false;
			// Apply a Y scale to the cursor to make it look as if it sits on the plane of the isometric floor.
			_arrowCursor.scaleY = 0.45;
			
			_walkSound = new EmbeddedAudio.OverSound();
		}

		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function cleanUp():void
		{
			super.cleanUp();
			
			_roomView.uiLayer.removeEventListener(MouseEvent.ROLL_OVER, onUiLayerMouseOver);
			_roomView.uiLayer.removeEventListener(MouseEvent.ROLL_OUT, onUiLayerMouseOut);
			_roomView.removeEventListener(MouseEvent.ROLL_OUT, onMouseOutRoom);
			_roomView.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownRoom);
			_roomView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpRoom);
			_roomView.removeEventListener(RoomItemDisplayEvent.MOUSE_OVER_ITEM, onMouseOverRoomItem);
			_roomView.removeEventListener(RoomItemDisplayEvent.MOUSE_OUT_ITEM, onMouseOutRoomItem);
			_roomView.removeEventListener(RoomItemDisplayEvent.MOUSE_CLICK_ITEM, onMouseClickRoomItem);
			_roomView.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			GameConsoleDelegate.gameConsole.removeEventListener('show pet menu', onGameConsolePetMenuClick);
			
			// Remove avatar menu.
			removeCurrentCircleMenu();
			
			// Clean up animation manager.
			// Calling dispose sometimes causes an error. Don't know why. Maybe becuase some animations have not finished. - Tommy
			//_animMan.dispose();
			_animMan = null;
			
			// Cleanup keyboard input controller.
			_keyboardInputController.removeEventListener(RoomKeyboardController.INPUT_DIRECTION, onInputDirectionChange);
			_keyboardInputController.destroy();
			_keyboardInputController = null;
			
			_mouseItemController = null;
			_mouseOverUiLayer = false;
			
			_roomView.setCursor(null);
		}
		
		override protected function setUp():void
		{
			super.setUp();
			
			// Defaults.
			_avatarInspectEnabled = true;
			_shopEnabled = true;
			_printInviteEnabled = true;
			_useItemRollOverLabel = true;
			_allowKeyboardWalking = false;
			
			// Create animation manager.
			_animMan = new AnimationManager();
			
			_roomView.uiLayer.addEventListener(MouseEvent.ROLL_OVER, onUiLayerMouseOver);
			_roomView.uiLayer.addEventListener(MouseEvent.ROLL_OUT, onUiLayerMouseOut);
			_roomView.addEventListener(MouseEvent.ROLL_OUT, onMouseOutRoom);
			_roomView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownRoom);
			_roomView.addEventListener(MouseEvent.MOUSE_UP, onMouseUpRoom);
			_roomView.addEventListener(RoomItemDisplayEvent.MOUSE_OVER_ITEM, onMouseOverRoomItem);
			_roomView.addEventListener(RoomItemDisplayEvent.MOUSE_OUT_ITEM, onMouseOutRoomItem);
			_roomView.addEventListener(RoomItemDisplayEvent.MOUSE_CLICK_ITEM, onMouseClickRoomItem);
			_roomView.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			GameConsoleDelegate.gameConsole.addEventListener('show pet menu', onGameConsolePetMenuClick);
			
			// Reset game console buttons.
			GameConsoleDelegate.gameConsole.resetDisabledButtons();
			
			// Create keyboard input controller and add keycode listeners.
			// W, A, S, D
			var roomViewDisplay:InteractiveObject = InteractiveObject(_roomView);
			roomViewDisplay.stage.focus = roomViewDisplay;
			_keyboardInputController = new RoomKeyboardController(roomViewDisplay.stage);
			_keyboardInputController.addEventListener(RoomKeyboardController.INPUT_DIRECTION, onInputDirectionChange);
		}
		
		protected function updateMouseCursor():void
		{
			// Determine which floor tile the mouse is over.
			// Set the cursor style based on the type of tile.
			
			// Get mouse coordinates.
			var renderLayer:RenderLayer = _roomView.getRenderLayer(RoomLayerType.FLOOR);
			if (!renderLayer) return;
			var p:Point = renderLayer.globalToLocal(_roomView.mouseX, _roomView.mouseY);
			// Translate mouse coordinates to tile coordinates and return a tile.
			var mapLayer:TileMap = _room.getMapLayer(RoomLayerType.FLOOR);
			
			//Sometimes when going into a flash game this is still around for a frame after the room is cleaned up
			// Just exit then as there is nothing to update.
			if(mapLayer == null)
			{
				return;
			}
			
			var tile:IOccupancyTile = mapLayer.getTile(Math.floor(p.x), Math.floor(p.y));
			var triggerTile:TriggerTile = tile as TriggerTile;
			
			// Check if there is a tile under the mouse.
			if (!tile)
			{
				// Theres NO tile under the mouse.
				// Use the system cursor.
				_roomView.setCursor(null);
				_roomView.hideCustomCursor = true;
			}
			else if (triggerTile)
			{
				// Check for specific types of trigger tiles to handle differently.
				if (triggerTile.tileSetID && (triggerTile.tileSetID.indexOf('gamequeue') == 0 || triggerTile.tileSetID.indexOf('system_walk') == 0))
				{
					// This is either a game queue tile or a system walk tile.
					// Game queue tiles are tiles that users stand on when waiting in queue to launch a multiplayer game.
					// System walk tiles are tiles that can be walked on but not directly walked to by users.
					// Don't allow walking to this tile and treat as if no tile is here.
					_roomView.setCursor(null);
					_roomView.hideCustomCursor = true;
				}
				else
				{
					// Set cursor angle.
					_arrowCursor.angle = getLocalAvatarToMouseAngle();
					// If the tile is a trigger tile, give it a specific style.
					_arrowCursor.fillColor = 0x3e6d99;
					_arrowCursor.lineColor = 0xffffff;
					// Make sure we're using the custom cursor.
					_roomView.setCursor(_arrowCursor);
					_roomView.hideCustomCursor = false;
				}
			}
			else
			{
				// Set cursor angle.
				_arrowCursor.angle = getLocalAvatarToMouseAngle();
				// There's a tile under the mouse but it's not a trigger tile.
				// Give the cursor a standard style.
				_arrowCursor.fillColor = 0xffc05c;
				_arrowCursor.lineColor = 0x0000000;
				// Make sure we're using the custom cursor.
				_roomView.setCursor(_arrowCursor);
				_roomView.hideCustomCursor = false;
			}
		}
		
		override protected function handleAddedItemController(itemController:IRoomItemController):void
		{
			super.handleAddedItemController(itemController);
			
			// Determine class id.
			var itemClassId:int = itemController.item.itemClassId;
			
			// Listen to all items for these events.
			itemController.addEventListener(GameLauncherEvent.CLICKED, onGameLaunchClick);
		}
		
		override protected function handleRemovedItemController(itemController:IRoomItemController):void
		{
			// Determine class id.
			var itemClassId:int = itemController.item.itemClassId;
			
			// Remove these listeners from all items.
			itemController.removeEventListener(GameLauncherEvent.CLICKED, onGameLaunchClick);
			
			// If the user had this item selected, remove the circle menu.
			if (_selectedRoomItemController && _selectedRoomItemController.item.id == itemController.item.id)
			{
				removeCurrentCircleMenu();
			}
			
			// If the mouse was over this item, set the reference to null.
			if (_mouseItemController && _mouseItemController.item.id == itemController.item.id) _mouseItemController = null;
			
			super.handleRemovedItemController(itemController);
		}
		
		protected function handleCurrentInputDirection():Point
		{
			// We want the user to walk in the input direction.
			// To achieve this efficiently, we find the furthest walkable tile in the input direction and have the user walk there.
			// If there is no input direction, we have the user do a walk to its current tile. This gives the appearance of stopping.
			if (!_allowKeyboardWalking) return new Point();
			
			// Return the distance of the tile that the user is walking to.
			var walkDistance:Point;
			
			var inputDirection:Point = _keyboardInputController.inputDirection;
			if (Math.abs(inputDirection.x) > 0 || Math.abs(inputDirection.y) > 0)
			{
				// Get floor layer.
				var floorTileMap:TileMap = _room.getMapLayer(RoomLayerType.FLOOR);
				// Get furthest walkable tile in direction.
				var walkPoint:Point = floorTileMap.getFurthestTilePositionInDirectPathFromPoint(userController.entity.x, userController.entity.y, inputDirection.x, inputDirection.y);
				// Calculate walk distance.
				walkDistance = new Point(walkPoint.x - userController.entity.x, walkPoint.y - userController.entity.y);
				// Walk.
				if (Math.abs(walkDistance.x) > 0.5 || Math.abs(walkDistance.y) > 0.5) userController.walk(walkPoint.x, walkPoint.y);
			}
			else
			{
				// No walk distance.
				// If user is moving, have them walk to their current position, to give the appearance of stopping.
				walkDistance = new Point(0, 0);
				if (userController.entity.motionEnabled) userController.walk(userController.entity.x, userController.entity.y);
			}
			
			// Return the distance of the tile that the user is walking to.
			return walkDistance;
		}
		
		protected function stylizeSelectedRoomItem(itemController:IRoomItemController, isSelected:Boolean):void
		{
			if (isSelected)
			{
				if (itemController.display) itemController.display.filters = [_SELECTED_ITEM_GLOW];
			}
			else
			{
				if (itemController.display) itemController.display.filters = [];
			}
		}
		
		protected function showPopUp(display:DisplayObject, backingAlpha:Number = 0.8):void
		{
			var duration:int = 300;
			var container:Sprite = new Sprite();
			var backing:Sprite = new Sprite();
			backing.graphics.beginFill(0x000000, backingAlpha);
			backing.graphics.drawRect(0, 0, 925, 665);
			container.addChild(backing);
			
			display.x = container.width / 2 - display.width / 2;
			display.y = container.height / 2 - display.height / 2;
			container.addChild(display);
			
			RoomManager.getInstance().addEventListener(RoomManagerEvent.ENTER_ROOM_START, onEnterRoomStart);
			backing.addEventListener(MouseEvent.CLICK, onBackingClick);
			
			// Timer used handle closing & cleaning up of the pop up when changing rooms.
			var closeTimer:Timer = new Timer(duration);
			
			container.alpha = 0;
			_roomView.addPopUp(container);
			
			// Animate the avatar display.
			_animMan.alpha(container, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onBackingClick(e:MouseEvent):void
			{
				// Close the pop up.
				closePopUp();
			}
			
			function onEnterRoomStart(e:Event):void
			{
				// Close item info panel.
				closePopUp();
			}
			
			function closePopUp():void
			{
				// Remove listeners.
				RoomManager.getInstance().removeEventListener(RoomManagerEvent.ENTER_ROOM_START, onEnterRoomStart);
				backing.removeEventListener(MouseEvent.CLICK, onBackingClick);
				
				// Animate the item display.
				closeTimer.addEventListener(TimerEvent.TIMER, onCloseTimer);
				_animMan.alpha(container, 0, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				closeTimer.start();
			}
			
			function onCloseTimer(e:TimerEvent):void
			{
				// Remove timer.
				closeTimer.removeEventListener(TimerEvent.TIMER, onCloseTimer);
				closeTimer.reset();
				closeTimer = null;
				
				// Close the item info panel.
				_roomView.removePopUp(container);
				container = null;
				
				// Try to call cleanup method on item info panel.
				var displayObject:Object = display;
				if (displayObject.destroy) displayObject.destroy();
				displayObject = null;
				display = null;
			}
		}
		
		protected function handleAvatarDoubleClick():void
		{
			// Get reference to avatar.
			var avatar:Avatar = _selectedRoomItemController.item as Avatar;
			// Check if it is the local avatar.
			if (avatar.avatarId == _localAvatar.avatarId)
			{
				// If it's the local avatar, show in the PDA.
				PDAController.getInstance().showAvatar(_localAvatar);
			}
			else
			{
				// Show an avatar info panel.
				showItemInfoPanel(_selectedRoomItemController, 0);
			}
			
			// Remove current circle menu.
			removeCurrentCircleMenu(true);
			
			// Log this event.
			LoggingUtil.sendClickLogging(2835);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function removeCurrentCircleMenu(animate:Boolean = false):void
		{
			if (!_selectedRoomItemController) return;
			
			// Store reference to previous menu.
			_previousSelectedRoomItemController = _selectedRoomItemController;
			_previousCircleMenu = _currentCircleMenu;
			var previousCircleMenu:RoomItemCircleMenu = _previousCircleMenu;
			
			// Remove highlight from previously selected item.
			if (_previousSelectedRoomItemController) stylizeSelectedRoomItem(_previousSelectedRoomItemController, false);
			
			// Null current.
			if (_selectedRoomItemController == _mouseItemController) _mouseItemController = null;
			_currentCircleMenu = null;
			_selectedRoomItemController = null;
			
			RoomManager.getInstance().dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.CIRCLE_MENU_REMOVED_FROM_STAGE));
			
			// Stop listening for user interaction.
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_INSPECT, onRoomItemMenuInspectClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_HOME, onAvatarMenuHomeClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_FRIEND, onAvatarMenuFriendClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_IGNORE, onAvatarMenuIgnoreClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_EMOTE, onAvatarMenuEmoteClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_JAB, onAvatarMenuJabClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_SHOP, onAvatarMenuShopClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_PRINT, onAvatarMenuPrintClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_MVP, onAvatarMenuMvpClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_INVITE, onAvatarMenuInviteClick);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_INVITE_TO_GAME, onInviteToGameClick);
			_previousCircleMenu.removeEventListener(PetCircleMenu.CLICK_ACTION, onPetCircleMenuClickAction);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_FEED_PET, onPetCircleMenuClickFeed);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_PLAY_PET, onPetCircleMenuClickPlay);
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.CLICK_STAY_PET, onPetCircleMenuClickStay);
			
			// Stop listening for menu roll out.
			_previousCircleMenu.removeEventListener(MouseEvent.ROLL_OUT, onCircleMenuRollOut);
			
			// Stop having the menu follow the item.
			_previousSelectedRoomItemController.removeEventListener(RoomItemEvent.MOVE, onSelectedItemMove);
			
			if (animate)
			{
				// Hide the previous menu.
				previousCircleMenu.addEventListener(RoomItemCircleMenuEvent.HIDE_FINISH, onPreviousCircleMenuHideFinish);
				previousCircleMenu.hide(true);
			}
			else
			{
				// Remove item menu.
				previousCircleMenu.hide(false);
				
				// Remove previous circle menu.
				onHideFinish();
			}
			
			function onHideFinish():void
			{
				// Remove previous circle menu.
				_roomView.uiLayer.removeChild(previousCircleMenu);
				previousCircleMenu.destroy();
			}
			
			function onPreviousCircleMenuHideFinish(e:Event):void
			{
				// Remove previous circle menu.
				previousCircleMenu.addEventListener(RoomItemCircleMenuEvent.HIDE_FINISH, onPreviousCircleMenuHideFinish);
				onHideFinish();
			}
		}
		
		private function getLocalAvatarToMouseAngle():Number
		{
			// Determine angle from local avatar to mouse cursor.
			// In radians.
			var avatarDisplay:IRoomItemDisplay = userController.display;
			var avRect:Rectangle = avatarDisplay.getImageRect();
			var avX:Number = avatarDisplay.x + avRect.x + avRect.width / 2;
			var avY:Number = avatarDisplay.y + avRect.y + avRect.height;
			var offX:Number = _roomView.mouseX - avX;
			var offY:Number = _roomView.mouseY - avY;
			var angle:Number = Math.atan2(offY, offX);
			
			return angle;
		}
		
		private function positionCircleMenu():void
		{
			// Ideally this offset would come from the sprite template, but since the avatar and pet share the same template.
			// Currently the pets use an inaccurate sprite template.
			var offX:Number = 60;
			var offY:Number = 60;
			if (_selectedRoomItemController.item.itemTypeId == ItemType.PETS)
			{
				var imgRect:Rectangle = _selectedRoomItemController.display.getImageRect();
				offX = imgRect.x + imgRect.width / 2;
				offY = imgRect.y + imgRect.height / 2;
			}
			
			var newX:Number = _selectedRoomItemController.display.x + offX;
			var newY:Number = _selectedRoomItemController.display.y + offY;

			// Constrain to the size of the screen.
			var minX:Number = _currentCircleMenu.width / 2;
			var maxX:Number = 925 - minX;
			var minY:Number = minX;
			var maxY:Number = 615 - minX;
			newX = Math.max(newX, minX);
			newX = Math.min(newX, maxX);
			newY = Math.max(newY, minY);
			newY = Math.min(newY, maxY);
			
			_currentCircleMenu.x = newX;
			_currentCircleMenu.y = newY;
		}
		
		private function selectRoomItem(itemController:IRoomItemController):void
		{
			// Select the specified item.
			// Show a circle menu over this item.
			
			// Make sure it's not already selected.
			if (itemController == _selectedRoomItemController) return;
			
			// Add new circle menu to foreground layer.
			// Determine which type of circle menu will be used based on the type of item.
			// Only show circle menus for Avatars & Pets.
			var item:SdgItem = itemController.item;
			var menuLabel:String = item.name;
			var circleMenu:RoomItemCircleMenu;
			if (item.itemClassId == SdgItemClassId.AVATAR)
			{
				// The item is an avatar.
				// Determine if the selected item is the local avatar.
				var avatar:Avatar = item as Avatar;
				var isLocalAvatar:Boolean = _localAvatar.avatarId == avatar.avatarId;
				if (isLocalAvatar)
				{
					// The item is the local avatar.
					menuLabel = 'You';
					var isMvp:Boolean = (avatar.membershipStatus == MembershipStatus.PREMIUM);
					var emoteList:Array = ModelLocator.getInstance().emoteList;
					circleMenu = new LocalAvatarCircleMenu(menuLabel, isMvp, emoteList, _avatarInspectEnabled, _shopEnabled, _printInviteEnabled);
					
					RoomManager.getInstance().dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.LOCAL_CIRCLE_MENU_ADDED_TO_STAGE));
				}
				else
				{
					// The item is an avatar but NOT the local avatar.
					var isFriend:Boolean = BuddyManager.isBuddy(avatar.avatarId);
					var isIgnored:Boolean = ModelLocator.getInstance().ignoredAvatars[avatar.avatarId];
					var jabList:Array = ModelLocator.getInstance().jabList;
					// Determine if we should show the game invite button.
					// This should be shown if the local avatar is currently trying to start a game and invite people.
					var isInvitableToGame:Boolean = _roomManager.userController.inviteModeOn;
					circleMenu = new AvatarCircleMenu(menuLabel, isFriend, isIgnored, jabList, isInvitableToGame, _avatarInspectEnabled, _localAvatar.membershipStatus != MembershipStatus.GUEST);
				}
				
			}
			else if (item.itemTypeId == ItemType.PETS)
			{
				// The item is a pet.
				var petItem:PetItem = item as PetItem;
				// Make sure we are not currently in edit mode.
				if (_room.editMode) return;
				// Determine if pet is leashed.
				var isPetLeashed:Boolean = (_localAvatar.leashedPetInventoryId == item.id);
				// Only the pet owner can feed the pet.
				var canFeed:Boolean = (_localAvatar.avatarId == item.avatarId);
				// Only the pet owner can leash/unleash the pet.
				var canLeash:Boolean = canFeed;
				// Anyone can play with pets for now.
				var canPlay:Boolean = true;
				// Only pet owner can stay/follow.
				var canStay:Boolean = (isPetLeashed && canFeed);
				// Get dimensions of pet sprite.
				var imgRect:Rectangle = itemController.display.getImageRect(true);
				var maxRadius:Number = 50;
				var minRadius:Number = 45;
				var circleMenuRadius:Number = Math.max(Math.min(Math.max(imgRect.width, imgRect.height) + 10, maxRadius), minRadius);
				circleMenu = new PetCircleMenu(menuLabel, isPetLeashed, petItem.isFollowingOwner, canFeed, canPlay, canLeash, canStay, circleMenuRadius);
			}
			
			// Remove previous circle menu.
			if (_selectedRoomItemController)
			{
				removeCurrentCircleMenu(true);
			}
			
			// Add highlight to selected item.
			stylizeSelectedRoomItem(itemController, true);
			
			// Initialy hide the menu before we show it.
			circleMenu.hide();
			_roomView.uiLayer.addChild(circleMenu);
			
			// Set instance references.
			_selectedRoomItemController = itemController;
			_currentCircleMenu = circleMenu;
			
			// Positon and show the circle menu.
			positionCircleMenu();
			circleMenu.addEventListener(RoomItemCircleMenuEvent.SHOW_FINISH, onShowFinish);
			circleMenu.addEventListener(MouseEvent.CLICK, onMenuClickBeforeShow);
			circleMenu.show(true);
			
			// Add circle menu interaction listeners.
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_INSPECT, onRoomItemMenuInspectClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_HOME, onAvatarMenuHomeClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_FRIEND, onAvatarMenuFriendClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_IGNORE, onAvatarMenuIgnoreClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_EMOTE, onAvatarMenuEmoteClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_JAB, onAvatarMenuJabClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_SHOP, onAvatarMenuShopClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_PRINT, onAvatarMenuPrintClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_MVP, onAvatarMenuMvpClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_INVITE, onAvatarMenuInviteClick);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_INVITE_TO_GAME, onInviteToGameClick);
			_currentCircleMenu.addEventListener(PetCircleMenu.CLICK_ACTION, onPetCircleMenuClickAction);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_FEED_PET, onPetCircleMenuClickFeed);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_PLAY_PET, onPetCircleMenuClickPlay);
			_currentCircleMenu.addEventListener(RoomItemCircleMenuEvent.CLICK_STAY_PET, onPetCircleMenuClickStay);
			
			// Listen for when the item moves so we cvan make the menu follow the item.
			itemController.addEventListener(RoomItemEvent.MOVE, onSelectedItemMove);
			
			// Listen for mouse out on the menu so we can eventually hide the menu.
			_currentCircleMenu.addEventListener(MouseEvent.ROLL_OUT, onCircleMenuRollOut);
			
			function onShowFinish(e:RoomItemCircleMenuEvent):void
			{
				// Remove listeners.
				circleMenu.removeEventListener(RoomItemCircleMenuEvent.SHOW_FINISH, onShowFinish);
				circleMenu.removeEventListener(MouseEvent.CLICK, onMenuClickBeforeShow);
			}
			
			function onMenuClickBeforeShow(e:MouseEvent):void
			{
				// Remove listeners.
				circleMenu.removeEventListener(RoomItemCircleMenuEvent.SHOW_FINISH, onShowFinish);
				circleMenu.removeEventListener(MouseEvent.CLICK, onMenuClickBeforeShow);
				
				// If the user clicks on the circle menu before it has finished showing, consider it a double click.
				// If the selected item is an avatar, shwo that avatar info.
				if (_currentCircleMenu != circleMenu || !_selectedRoomItemController) return;
				// Make sure the selected item is an avatar.
				if (_selectedRoomItemController.item.itemClassId != SdgItemClassId.AVATAR) return;
				handleAvatarDoubleClick();
			}
		}
		
		private function showItemInfoPanel(itemController:IRoomItemController, backingAlpha:Number = 0.8):void
		{
			// Show item info panel.
			// Use a different display depending on the type of item.
			// Currently only supports avatars or pets.
			var itemInfoPanel:DisplayObject;
			
			var item:SdgItem = itemController.item;
			
			// Create info panel based on type of item.
			if (item.itemClassId == SdgItemClassId.AVATAR)
			{
				// Use avatar info panel.
				var avatar:Avatar = item as Avatar;
				itemInfoPanel = new IntegratedAvatarInfoPanel(avatar, 340, 520, true);
			}
			else if (item.itemTypeId == ItemType.PETS)
			{
				// Use pet info panel.
				itemInfoPanel = new IntegratedPetInfoPanel(itemController as PetController);
			}
			else
			{
				// This function does ot support any other item types.
				return;
			}
			
			showPopUp(itemInfoPanel, backingAlpha);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function onMouseOutRoom(e:MouseEvent):void
		{
			// Hide custom cursor.
			_roomView.hideCustomCursor = true;
			_roomView.setCursor(null);
		}
		
		protected function onMouseDownRoom(e:MouseEvent):void
		{
			// If there is no mouse item, walk to tile.
			if (_mouseItemController) return;
			
			// Make sure the mouse is not over the UI layer.
			if (_mouseOverUiLayer) return;
			
			// Walk to tile under mouse point.
			var renderLayer:RenderLayer = _roomView.getRenderLayer(RoomLayerType.FLOOR);
			var p:Point = renderLayer.globalToLocal(_roomView.mouseX, _roomView.mouseY);
			
			var mapLayer:TileMap = _room.getMapLayer(RoomLayerType.FLOOR);
			// Sometimes when going into a flash game this is still around for a frame after the room is cleaned up
			// Just exit then as there is nothing to update.
			if (mapLayer == null)
			{
				return;
			}
			var tile:IOccupancyTile = mapLayer.getTile(Math.floor(p.x), Math.floor(p.y));
			
			var tileOccupant:IMapOccupant = (tile != null) ? tile.getOccupant() : null;
			var tileIsOccupiedBySolid:Boolean = (tileOccupant != null) ? tileOccupant.solidity > 0 : false;
			
			// Make sure there is a tile and the tile is not occupied.
			// Also make sure the tile is not a game queue tile or a system walk tile.
			// "system_walk" tiles are tiles that can be walked on but we don't allow users to walk there themselves.
			if (tile && !tileIsOccupiedBySolid && !(tile.tileSetID && (tile.tileSetID.indexOf('gamequeue') == 0 || tile.tileSetID.indexOf('system_walk') == 0))) userController.walk(Math.floor(p.x), Math.floor(p.y));
			
			// Play the walk sound.
			_walkSound.play();
			
			// Remove avatar menu.
			removeCurrentCircleMenu(true);
			
			// Animate the custom cursor to squish down.
			// Also animate it to white.
			_animMan.property(_arrowCursor, 'stretchPercentage', 0.6, 200, Transitions.BACK_OUT, RenderMethod.TIMER);
			_animMan.property(_arrowCursor, 'fillColor', 0xffffff, 100, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function onMouseUpRoom(e:MouseEvent):void
		{
			// Make sure the mouse is not over an item or the UI layer.
			if (_mouseItemController || _mouseOverUiLayer) return;
			
			// Animate the custom cursor to it's original size and color.
			_animMan.property(_arrowCursor, 'stretchPercentage', 1, 200, Transitions.BACK_OUT, RenderMethod.TIMER);
			_animMan.property(_arrowCursor, 'fillColor', 0xffc05c, 400, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function onMouseOverRoomItem(e:RoomItemDisplayEvent):void
		{
			// Determine item controller.
			_mouseItemController = getItemController(e.display.item);
			
			// Hide the custom cursor.
			_roomView.hideCustomCursor = true;
			_roomView.setCursor(null);
			
			// Make sure the item is an avatar or pet.
			if (_mouseItemController.item.itemClassId != SdgItemClassId.AVATAR &&
				_mouseItemController.item.itemTypeId !=ItemType.PETS &&
				_mouseItemController.item.itemTypeId !=ItemType.NPC) 
				 return;
			
			// If it's an Avatar or Pet, give the item a specific highlight and label.
			
			// Get reference to item display.
			var itemController:IRoomItemController = _mouseItemController;
			var itemDisplay:IRoomItemDisplay = itemController.display;
			// Add highlight.
			var originalFilters:Array = itemDisplay.filters;
			itemDisplay.filters = [_SELECTED_ITEM_GLOW];
			
			// Create a name label and have it follow the item.
			// Remove it on mouse out.
			var nameLabel:TextField;
			if (_useItemRollOverLabel)
			{
				nameLabel = new TextField();
				nameLabel.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
				nameLabel.autoSize = TextFieldAutoSize.CENTER;
				nameLabel.selectable = false;
				nameLabel.mouseEnabled = false;
				nameLabel.embedFonts = true;
				nameLabel.text = itemController.item.name;
				nameLabel.filters = [new GlowFilter(0, 1, 2, 2, 10)];
				positionNameLabel();
				_roomView.uiLayer.addChild(nameLabel);
				
				// Listen for when the item moves so we can make the name label follow.
				itemController.addEventListener(RoomItemEvent.MOVE, onItemMove);
			}
			
			// Listen for mouse out so we can remove the highlight at some point.
			itemDisplay.addEventListener(RoomItemDisplayEvent.MOUSE_OUT_ITEM, onMouseOut);
			
			function onMouseOut(e:RoomItemDisplayEvent):void
			{
				// Remove item highlight.
				// If the item has been selected, don't remove the highlight.
				itemDisplay.removeEventListener(RoomItemDisplayEvent.MOUSE_OUT_ITEM, onMouseOut);
				if (!_selectedRoomItemController || _selectedRoomItemController.display != itemDisplay) itemDisplay.filters = originalFilters;
				
				// Stop having the name label follow the item.
				if (nameLabel)
				{
					// Remove the name label.
					itemController.removeEventListener(RoomItemEvent.MOVE, onItemMove);
					_roomView.uiLayer.removeChild(nameLabel);
					nameLabel = null;
				}
				
			}
			
			function onItemMove(e:RoomItemEvent):void
			{
				// Re-position the name label.
				positionNameLabel();
			}
			
			function positionNameLabel():void
			{
				var itemImageRect:Rectangle = itemDisplay.getImageRect();
				nameLabel.x = itemDisplay.x + itemImageRect.x + itemImageRect.width / 2 - nameLabel.width / 2;
				nameLabel.y = itemDisplay.y + itemImageRect.y + itemImageRect.height + 5;
			}
		}
		
		private function onMouseOutRoomItem(e:RoomItemDisplayEvent):void
		{
			_mouseItemController = null;
		}
		
		private function onMouseClickRoomItem(e:RoomItemDisplayEvent):void
		{
			// Get reference to item controller.
			var item:SdgItem = e.display.item;
			var itemController:IRoomItemController = getItemController(item, false);
			
			// If it's an Avatar or Pet, select the item
			if (item.itemClassId == SdgItemClassId.AVATAR || item.itemTypeId == ItemType.PETS) selectRoomItem(itemController);
		}
		
		private function onGameConsolePetMenuClick(ev:Event):void
		{
			// If the local avatar has a leashed pet, show the pet info panel.
			var leashedPetInventoryId:int = _localAvatar.leashedPetInventoryId;
			if (leashedPetInventoryId < 1) return;
			// Get reference to pet item controller.
			var petItem:InventoryItem = _room.getInventoryItemById(leashedPetInventoryId);
			var petItemController:IRoomItemController = getItemController(petItem, false);
			if (petItemController) showItemInfoPanel(petItemController, 0);
			
			LoggingUtil.sendClickLogging(4233);
		}
		
		private function onUiLayerMouseOver(e:MouseEvent):void
		{
			// Hide custom cursor.
			_roomView.hideCustomCursor = true;
			_roomView.setCursor(null);
			// Set flag.
			_mouseOverUiLayer = true;
		}
		
		private function onUiLayerMouseOut(e:MouseEvent):void
		{
			_mouseOverUiLayer = false;
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			// Make sure a room item has not been moused over.
			if (_mouseItemController) return;
			
			// Make sure the mouse is not over the UI layer.
			if (_mouseOverUiLayer) return;
			
			// If there's no mouse item, re-draw the arrow cursor.
			updateMouseCursor();
		}
		
		private function onGameLaunchClick(e:GameLauncherEvent):void
		{
			// Propegate the event through the room view.
			var event:GameLauncherEvent = new GameLauncherEvent(e.type, e.bubbles, e.cancelable);
			_roomView.dispatchEvent(event);
		}
		
		private function onSelectedItemMove(e:RoomItemEvent):void
		{
			// When the avatar moves, make the circle menu follow.
			positionCircleMenu();
		}
		
		private function onPreviousCircleMenuHideFinish(e:Event):void
		{
			// Remove listener.
			_previousCircleMenu.removeEventListener(RoomItemCircleMenuEvent.HIDE_FINISH, onPreviousCircleMenuHideFinish);
			
			// Stop having the menu follow the selected item.
			_previousSelectedRoomItemController.removeEventListener(RoomItemEvent.MOVE, onSelectedItemMove);
			
			// Remove previous circle menu.
			_roomView.uiLayer.removeChild(_previousCircleMenu);
			_previousCircleMenu.destroy();
			_previousCircleMenu = null;
			_previousSelectedRoomItemController = null;
		}
		
		private function onCircleMenuRollOut(e:MouseEvent):void
		{
			// Create local reference to circle menu.
			var circleMenu:RoomItemCircleMenu = _currentCircleMenu;
			
			// If the user is mouse out from the circle menu for 1 second, hide the menu.
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			circleMenu.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				// Kill the timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				
				// Remove listener.
				circleMenu.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				
				// Hide the circle menu.
				// Make sure the current circle menu is the same as it was when we initially got the roll out event.
				if (circleMenu == _currentCircleMenu) removeCurrentCircleMenu(true);
			}
			
			function onRollOver(e:MouseEvent):void
			{
				// Remove listener.
				circleMenu.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				
				// Kill the timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
			}
		}
		
		private function onAvatarMenuHomeClick(e:RoomItemCircleMenuEvent):void
		{
			// Send to avatars home turf.
			if (!_selectedRoomItemController) return;
			
			// Send to avatars home turf.
			var selectedAvatar:Avatar = _selectedRoomItemController.item as Avatar;
			var roomId:String = 'private_' + selectedAvatar.avatarId + '_1';
			// Make sure the user is registered.
			if (_localAvatar.membershipStatus == MembershipStatus.GUEST &&
				(selectedAvatar.id == _localAvatar.id))
			{
				MainUtil.showDialog(SaveYourGameDialog);
			}
			else
			{
				CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			}
			
			// Remove avatar menu.
			removeCurrentCircleMenu(true);
			
			// Log this event.
			// Different id, based on whether it's your turf or another user's turf.
			LoggingUtil.sendClickLogging((selectedAvatar.id == _localAvatar.id) ? 2832 : 2840);
		}
		
		private function onRoomItemMenuInspectClick(e:RoomItemCircleMenuEvent):void
		{
			// Show avatar info for selected avatar.
			if (!_selectedRoomItemController) return;
			
			// Determine if the item is an avatar or pet.
			if (_selectedRoomItemController.item.itemClassId == SdgItemClassId.AVATAR)
			{
				// The selected item is an avatar.
				// Check if it is the local avatar.
				var avatar:Avatar = _selectedRoomItemController.item as Avatar;
				if (avatar.avatarId == _localAvatar.avatarId)
				{
					// If it's the local avatar, show in the PDA.
					PDAController.getInstance().showAvatar(_localAvatar);
				}
				else
				{
					// Show an avatar info panel.
					showItemInfoPanel(_selectedRoomItemController, 0);
				}
				
				// Log this event.
				LoggingUtil.sendClickLogging(2830);
			}
			else if (_selectedRoomItemController.item.itemTypeId == ItemType.PETS)
			{
				// The selected item is a pet.
				// Show a pet info panel.
				showItemInfoPanel(_selectedRoomItemController, 0);
			}
			
			// Remove avatar menu.
			removeCurrentCircleMenu(true);
		}
		
		private function onAvatarMenuFriendClick(e:RoomItemCircleMenuEvent):void
		{
			// Add/Remove selected avatar as buddy.
			if (!_selectedRoomItemController) return;
			
			var selectedAvatar:Avatar = _selectedRoomItemController.item as Avatar;
			var isBuddyAlready:Boolean = BuddyManager.isBuddy(selectedAvatar.avatarId);
			
			// Log this event.
			// Depends whteher they are already a friend or not.
			LoggingUtil.sendClickLogging((isBuddyAlready) ? 2838 : 2837);
			
			if (!isBuddyAlready)
			{
				// The selected avatar is not yet a buddy.
				// Send a buddy request.
				
				// Make sure the local avatar is not a guest.
				if (_localAvatar.membershipStatus == MembershipStatus.GUEST)
				{
					// Show MVP upsell.
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}
				
				// Make sure the selected avatar is not a guest.
				if (selectedAvatar.membershipStatus == MembershipStatus.GUEST)
				{
					// The selected buddy is a guest so the local avatar can NOT add them as a buddy.
					// Message this to the user.
					SdgAlertChrome.show("Oops! " + selectedAvatar.name + " is unable to send or accept buddy requests as a Guest Member.", "Time Out!");
					return;
				}
				
				// Add the buddy.
				BuddyManager.makeBuddyRequest(selectedAvatar.avatarId, selectedAvatar.name);
			}
			else
			{
				// The selected avatar is already a buddy.
				// Remove the buddy.
				BuddyManager.makeRemoveBuddyRequest(selectedAvatar.avatarId);
				//SocketClient.sendMessage("avatar_handler", "buddyRemove", "buddy", { avatarId:_localAvatar.avatarId, buddyAvatarId:selectedAvatar.avatarId, friendTypeId:1, statusId:2 } );
			}
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
		}
		
		private function onAvatarMenuIgnoreClick(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Either ignore or un-ignore the selected avatar.
			
			// Store local reference to selected avatar.
			var selectedAvatar:Avatar = _selectedRoomItemController.item as Avatar;
			
			// Determine if the selected avatar is currently ignore.
			var isIgnored:Boolean = ModelLocator.getInstance().ignoredAvatars[selectedAvatar.avatarId];
			
			// Toggle whether or not the selected avatar is ignored.
			ModelLocator.getInstance().ignoredAvatars[selectedAvatar.avatarId] = !isIgnored;
			
			// Message this to the user.
			var message:String = (!isIgnored) ? selectedAvatar.name + ' is now ignored.' : selectedAvatar.name + ' is no longer ignored.';
			var title:String = (!isIgnored) ? 'Ignored' : 'Unignored';
			SdgAlertChrome.show(message, title);
			
			// Log this action.
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "ignore", { ignoredAvatarId:selectedAvatar.avatarId, ignoreStatus:isIgnored ? 1 : 0 });
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
			
			// Log this event.
			LoggingUtil.sendClickLogging((isIgnored) ? 2843 : 2842);
		}
		
		private function onAvatarMenuEmoteClick(e:RoomItemCircleMenuEvent):void
		{
			// Trigger an emote.
			
			// Get emote name from event params.
			var eventParams:Object = e.params;
			var emoteName:String;
			var emoteUrl:String;
			if (eventParams && eventParams.emoteName && eventParams.emoteUrl)
			{
				emoteName = eventParams.emoteName;
				emoteUrl = eventParams.emoteUrl;
			}
			
			if (emoteName && emoteUrl)
			{
				// Trigger the emote.
				emoteUrl = Environment.getApplicationUrl() + emoteUrl;
				_roomManager.userController.emote(emoteUrl, null, false);
				
				// Remove avatar circle menu.
				removeCurrentCircleMenu(true);
			}
			else
			{
				// Log this event.
				// An emote was not triggered but the emote menu was opened.
				LoggingUtil.sendClickLogging(2831);
			}
		}
		
		private function onAvatarMenuJabClick(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Trigger a jab.
			// Have the local avatar jab the selected avatar.
			
			// Get event params.
			var selectedAvatar:Avatar = _selectedRoomItemController.item as Avatar;
			var eventParams:Object = e.params;
			var jabName:String;
			var jabId:int;
			if (eventParams && eventParams.jabName && eventParams.jabId)
			{
				jabName = eventParams.jabName;
				jabId = eventParams.jabId;
			}
			
			if (jabName && jabId)
			{
				// Trigger jab.
				_roomManager.userController.jab(selectedAvatar.avatarId, selectedAvatar.name, jabId);
				
				// Remove avatar circle menu.
				removeCurrentCircleMenu(true);
			}
			else
			{
				// A jab was not triggered but the jab menu was opened.
				// Log this event.
				LoggingUtil.sendClickLogging(2841);
			}
		}
		
		private function onAvatarMenuShopClick(e:RoomItemCircleMenuEvent):void
		{
			// Determine which shop should be opened, based on which room the user is in.
			
			// Get store id from room.
			var storeId:uint = (_room.storeId > 0) ? _room.storeId : StoreConstants.STORE_ID_RIVERWALK;
			var params:Object = new Object();
			params.storeId = storeId;
			// Open store module.
			AASModuleLoader.openStoreModule(params);
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
			
			// Log this event.
			LoggingUtil.sendClickLogging(2833);
		}
		
		private function onAvatarMenuPrintClick(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Allow the user to print an invite.
			
			// Launch Refer A Friend.
			// Might be able to make this more efficient...
			var selectedAvatar:Avatar = _selectedRoomItemController.item as Avatar;
			var referControl:ReferAFriendController = new ReferAFriendController();
			referControl.refer(selectedAvatar, 1);
			referControl = null;
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
		}
		
		private function onAvatarMenuMvpClick(e:RoomItemCircleMenuEvent):void
		{
			// Show the user an MVP upsell screen.
			
			CustomMVPAlert.show(AssetUtil.GetGameAssetUrl(99, 'mvp_upsell_01.swf'), 3741, onUpsellClose);
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
			
			// Log this event.
			// User viewed this upsell.
			LoggingUtil.sendClickLogging(2844);
			
			function onUpsellClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;
				trace('Custom MVP upsell close.');
				if (identifier == 3741)
					MainUtil.goToMVP(identifier);
			}
		}
		
		private function onAvatarMenuInviteClick(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Invite the selected avatar to the local avatar's home turf.
			
			// Get selected avatar.
			var avatar:Avatar = _selectedRoomItemController.item as Avatar;
			_roomManager.userController.inviteAvatarToHomeTurf(avatar.avatarId, avatar.name);
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
			
			// Log this event.
			LoggingUtil.sendClickLogging(2839);
		}
		
		private function onPetCircleMenuClickAction(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Determine which type of action should be triggered.
			// Currently only expecting "animate" or "leash".
			// "leash" would act as a toggle between leash/unleash.
			var action:String = e.params.action as String;
			var petController:PetController = _selectedRoomItemController as PetController;
			if (!petController) return;
			if (action == 'leash')
			{
				// Leash/unleash the pet.
				var isPetLeashed:Boolean = (_localAvatar.leashedPetInventoryId == petController.item.id);
				if (isPetLeashed)
				{
					// Unleash pet.
					PetManager.unleashPet(petController.item.id);
				}
				else
				{
					// Leash pet.
					PetManager.leashPetToAvatar(_localAvatar, petController.item.id, _localAvatar.avatarId);
				}
			}
			
			// Check for a logging param.
			// Trigger a click log if so.
			if (e.params.clickLogId)
			{
				LoggingUtil.sendClickLogging(e.params.clickLogId);
			}
			
			// Remove current circle menu.
			removeCurrentCircleMenu(true);
		}
		
		private function onPetCircleMenuClickFeed(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Feed pet.
			PetManager.feedPetWithAvatarsFood(_localAvatar, _selectedRoomItemController.item.id, _selectedRoomItemController.item.avatarId);
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
		}
		
		private function onInviteToGameClick(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Get selected avatar.
			var avatar:Avatar = _selectedRoomItemController.item as Avatar;
			// Send invite to avatar.
			_roomManager.userController.sendInvite(avatar);
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
		}
		
		private function onPetCircleMenuClickPlay(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Play with pet.
			var petController:PetController = _selectedRoomItemController as PetController;
			PetManager.playWithPet(petController.item.id);
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
		}
		
		private function onPetCircleMenuClickStay(e:RoomItemCircleMenuEvent):void
		{
			if (!_selectedRoomItemController) return;
			
			// Get referende to pet contoller.
			var petController:PetController = _selectedRoomItemController as PetController;
			
			// Toggle whether or not the leashed pet will follow the avatar.
			var doFollow:int = (petController.petItem.isFollowingOwner) ? 0 : 1;
			PetManager.setPetFollowMode(_selectedRoomItemController.item.id, doFollow);
			
			// Remove avatar circle menu.
			removeCurrentCircleMenu(true);
		}
		
		protected function onInputDirectionChange(e:Event):void
		{
			handleCurrentInputDirection();
		}
		
	}
}

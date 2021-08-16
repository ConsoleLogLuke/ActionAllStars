package com.sdg.view.avatarcard
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.control.BuddyManager;
	import com.sdg.control.room.RoomManager;
	import com.sdg.display.AvatarSprite;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.Buddy;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.LayeredImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class IntegratedAvatarInfoPanel extends Sprite
	{
		private var _avInfoPanel:AvatarInfoPanel;
		private var _avatar:Avatar;
		private var _avatarBackground:DisplayObject;
		private var _avatarBackgroundId:int;
		private var _isInitalLoad:Boolean;
		
		public function IntegratedAvatarInfoPanel(avatar:Avatar, width:Number = 340, height:Number = 520, withControls:Boolean = false, withCloseButton:Boolean = false, isSidePanel:Boolean = false, reloadAvatarApparel:Boolean = false)
		{
			super();
			
			_avatar = avatar;
			
			// Add a new avatar info panel.
			var avatarImage:LayeredImage;
			var backgroundLoader:QuickLoader;
			var teamLogoLoader:QuickLoader;
			var isBackgroundComplete:Boolean = false;
			var isAvatarImageComplete:Boolean = false;
			var isTeamLogoComplete:Boolean = false;
			var isFriend:Boolean = BuddyManager.isBuddy(_avatar.avatarId);
			var isIgnored:Boolean = ModelLocator.getInstance().ignoredAvatars[_avatar.avatarId];
			var allowGoTo:Boolean = (avatar.roomId != null && avatar.roomId.length > 0 && isFriend);
			if (withControls)
			{
				if (isSidePanel)
				{
					_avInfoPanel = new AvatarInfoSidePanelWithControls(isFriend, isIgnored, allowGoTo, width, height);
				}
				else
				{
					_avInfoPanel = new AvatarInfoPanelWithControls(isFriend, isIgnored, allowGoTo, width, height);
				}
			}
			else
			{
				if (isSidePanel)
				{
					_avInfoPanel = new AvatarInfoSidePanel(width, height);
				}
				else
				{
					_avInfoPanel = new AvatarInfoPanel(width, height);
				}
			}
			
			_avInfoPanel.addEventListener('go to', onGoToClick);
			_avInfoPanel.addEventListener('visit turf', onVisitTurfClick);
			_avInfoPanel.addEventListener('friend', onAddFriendClick);
			_avInfoPanel.addEventListener('unfriend', onUnFriendClick);
			_avInfoPanel.addEventListener('ignore', onIgnoreClick);
			_avInfoPanel.addEventListener('unignore', onUnIgnoreClick);
			addChild(_avInfoPanel);
			
			// Listen for apparel change events.
			_avatar.addEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onApparelChange);
			
			// Determine if we should load avtar apparel list before downloading images of the apparel.
			if (reloadAvatarApparel)
			{
				// Load the avatar's apparel.
				CairngormEventDispatcher.getInstance().addEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);
				CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarApparelEvent(_avatar));
			}
			else
			{
				// Load avatar image.
				loadAvatarImage();
			}
			
			function onApparelListCompleted(event:AvatarApparelEvent):void
			{
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_COMPLETED, onApparelListCompleted);
				
				// Load avatar image.
				loadAvatarImage();
			}
			
			function loadAvatarImage():void
			{
				// Load avatar image.
				avatarImage = new LayeredImage();
				avatarImage.addEventListener(Event.COMPLETE, onAvatarImageComplete);
				avatarImage.loadItemImage(_avatar);
				
				// Load avatar background.
				var backgroundId:int = (_avatar.background) ? _avatar.background.itemId : 4167;
				var backgroundUrl:String = ItemUtil.GetPreviewUrl(backgroundId);
				_avatarBackgroundId = backgroundId;
				backgroundLoader = new QuickLoader(backgroundUrl, onBackgroundComplete);
				
				// Load team logo.
				if (_avatar.favoriteTeamId)
				{
					teamLogoLoader = new QuickLoader(AssetUtil.GetTeamLogoUrl(_avatar.favoriteTeamId), onTeamLogoComplete);
				}
				else
				{
					isTeamLogoComplete = true;
				}
			}
			
			function onAvatarImageComplete():void
			{
				// Remove event listener.
				avatarImage.removeEventListener(Event.COMPLETE, onAvatarImageComplete);
				
				// Set flag.
				isAvatarImageComplete = true;
				
				// Check if all assets have finished loading.
				checkComplete();
			}
			
			function onBackgroundComplete():void
			{
				// Set flag.
				isBackgroundComplete = true;
				
				// Check if all assets have finished loading.
				checkComplete();
			}
			
			function onTeamLogoComplete():void
			{
				// Set flag.
				isTeamLogoComplete = true;
				
				// Check if all assets have finished loading.
				checkComplete();
			}
			
			function checkComplete():void
			{
				// Check if the avatar image and background have finished loading.
				if (isAvatarImageComplete  && isBackgroundComplete && isTeamLogoComplete)
				{
					// Composite the image together.
					compositeImage();
				}
			}
			
			function compositeImage():void
			{
				if (!_avInfoPanel) return;
				
				// Composite avatar image and background together.
				// Also composite avatar stylizing.
				_avatarBackground = backgroundLoader.content;
				var background:Sprite = new Sprite();
				background.addChild(_avatarBackground);
				avatarImage.filters = AvatarSprite.DefaultAvatarPreviewFilters;
				avatarImage.x = background.width / 2 - avatarImage.width / 2;
				avatarImage.y = background.height / 2 - avatarImage.height / 2;
				var bitmapData:BitmapData = new BitmapData(background.width, background.height);
				background.addChild(avatarImage);
				bitmapData.draw(background);
				var compositeImage:Bitmap = new Bitmap(bitmapData, 'auto', true);
				var image:Sprite = new Sprite();
				image.addChild(compositeImage);
				
				// Get Team logo.
				var teamLogo:DisplayObject = (teamLogoLoader) ? DisplayObject(teamLogoLoader.content) : null;
				
				// Pass avatar info into avatar info panel.
				//if(_avInfoPanel != null)
				{
					_avInfoPanel.setInfo(_avatar.level, _avatar.subLevel, _avatar.levelName, image, _avatar.isPremiumMember, _avatar.name, _avatar.homeTurfValue, _avatar.badgeCount, teamLogo);
					_avInfoPanel.animateIn();
				
					// Set flag.
					_isInitalLoad = true;
				}
			}
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Handle cleanup.
			if (_avInfoPanel)
			{
				removeChild(_avInfoPanel);
				_avInfoPanel.destroy();
				
				_avInfoPanel.removeEventListener('go to', onGoToClick);
				_avInfoPanel.removeEventListener('visit turf', onVisitTurfClick);
				_avInfoPanel.removeEventListener('friend', onAddFriendClick);
				_avInfoPanel.removeEventListener('unfriend', onUnFriendClick);
				_avInfoPanel.removeEventListener('ignore', onIgnoreClick);
				_avInfoPanel.removeEventListener('unignore', onUnIgnoreClick);
			}
			
			// Remove listeners.
			_avatar.removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onApparelChange);
			
			_avInfoPanel = null;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onGoToClick(e:Event):void
		{
			// Go to the room of the selected avatar.
			// They must be buddies for this to work.
			var buddy:Buddy = BuddyManager.getBuddy(_avatar.avatarId);
			if (!buddy) return;
			var roomId:String = buddy.roomId;
			if (!roomId || roomId.length < 1) return;
			RoomManager.getInstance().teleportToRoom(roomId);
			
			// Log this event.
			LoggingUtil.sendClickLogging(2846);
		}
		
		private function onVisitTurfClick(e:Event):void
		{
			// Send to avatars home turf.
			var roomId:String = 'private_' + _avatar.avatarId + '_1';
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			
			// Log this event.
			LoggingUtil.sendClickLogging(2847);
		}
		
		private function onAddFriendClick(e:Event):void
		{
			// The selected avatar is not yet a buddy.
			// Send a buddy request.
			
			var isFriend:Boolean = BuddyManager.isBuddy(_avatar.avatarId);
			if (isFriend) return;
			
			// Log this event.
			LoggingUtil.sendClickLogging(2848);
			
			var localAvatar:Avatar = ModelLocator.getInstance().avatar;
			
			// Make sure the local avatar is not a guest.
			if (localAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				// Show MVP upsell.
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			
			// Make sure the selected avatar is not a guest.
			if (_avatar.membershipStatus == MembershipStatus.GUEST)
			{
				// The selected buddy is a guest so the local avatar can NOT add them as a buddy.
				// Message this to the user.
				SdgAlertChrome.show("Oops! " + _avatar.name + " is unable to send or accept buddy requests as a Guest Member.", "Time Out!");
				return;
			}
			
			// Add the buddy.
			BuddyManager.makeBuddyRequest(_avatar.avatarId, _avatar.name);
			
			// Update the info panel buttons.
			var infoPanelWithControls:AvatarInfoPanelWithControls = _avInfoPanel as AvatarInfoPanelWithControls;
			if (infoPanelWithControls) infoPanelWithControls.isFriend = true;
		}
		
		private function onUnFriendClick(e:Event):void
		{
			// The selected avatar is already a buddy.
			// Remove the buddy.
			var isFriend:Boolean = BuddyManager.isBuddy(_avatar.avatarId);
			if (!isFriend) return;
			var localAvatar:Avatar = ModelLocator.getInstance().avatar;
			BuddyManager.makeRemoveBuddyRequest(_avatar.avatarId);
			//SocketClient.sendMessage("avatar_handler", "buddyRemove", "buddy", { avatarId:localAvatar.avatarId, buddyAvatarId:_avatar.avatarId, friendTypeId:1, statusId:2 } );
			
			// Update the info panel buttons.
			var infoPanelWithControls:AvatarInfoPanelWithControls = _avInfoPanel as AvatarInfoPanelWithControls;
			if (infoPanelWithControls) infoPanelWithControls.isFriend = false;
		}
		
		private function onIgnoreClick(e:Event):void
		{
			// Determine if the selected avatar is currently ignore.
			var isIgnored:Boolean = ModelLocator.getInstance().ignoredAvatars[_avatar.avatarId];
			if (isIgnored) return;
			
			// Toggle whether or not the selected avatar is ignored.
			var isNowIgnored:Boolean = !isIgnored;
			ModelLocator.getInstance().ignoredAvatars[_avatar.avatarId] = isNowIgnored;
			
			// Message this to the user.
			var message:String = (isNowIgnored) ? _avatar.name + ' is now ignored.' : _avatar.name + ' is no longer ignored.';
			var title:String = (isNowIgnored) ? 'Ignored' : 'Unignored';
			SdgAlertChrome.show(message, title);
			
			// Tell server to ignore/unignore the user.
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "ignore", { ignoredAvatarId:_avatar.avatarId, ignoreStatus:isIgnored ? 1 : 0 });
			
			// Log this event.
			LoggingUtil.sendClickLogging((isIgnored) ? 2850 : 2849);
			
			// Update the info panel buttons.
			var infoPanelWithControls:AvatarInfoPanelWithControls = _avInfoPanel as AvatarInfoPanelWithControls;
			if (infoPanelWithControls) infoPanelWithControls.isIgnored = !isIgnored;
		}
		
		private function onUnIgnoreClick(e:Event):void
		{
			// Determine if the selected avatar is currently ignore.
			var isIgnored:Boolean = ModelLocator.getInstance().ignoredAvatars[_avatar.avatarId];
			if (!isIgnored) return;
			
			// Toggle whether or not the selected avatar is ignored.
			ModelLocator.getInstance().ignoredAvatars[_avatar.avatarId] = !isIgnored;
			
			// Message this to the user.
			var message:String = (!isIgnored) ? _avatar.name + ' is now ignored.' : _avatar.name + ' is no longer ignored.';
			var title:String = (!isIgnored) ? 'Ignored' : 'Unignored';
			SdgAlertChrome.show(message, title);
			
			// Log this action.
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "ignore", { ignoredAvatarId:_avatar.avatarId, ignoreStatus:isIgnored ? 1 : 0 });
			
			// Update the info panel buttons.
			var infoPanelWithControls:AvatarInfoPanelWithControls = _avInfoPanel as AvatarInfoPanelWithControls;
			if (infoPanelWithControls) infoPanelWithControls.isIgnored = !isIgnored;
		}
		
		private function onApparelChange(e:AvatarApparelEvent):void
		{
			// Make sure the avatar image has been loaded since initialization.
			if (!_isInitalLoad) return;
			
			// Cover the avatar image while "changing clothes".
			_avInfoPanel.coverImage();
			
			// Re-load avatar image.
			var backgroundLoader:QuickLoader;
			var avatarImage:LayeredImage = new LayeredImage();
			avatarImage.addEventListener(Event.COMPLETE, onAvatarImageComplete);
			avatarImage.loadItemImage(_avatar);
			
			function onAvatarImageComplete():void
			{
				// Remove event listener.
				avatarImage.removeEventListener(Event.COMPLETE, onAvatarImageComplete);
				
				// Determine if we need to load the background again.
				var backgroundId:int = (_avatar.background) ? _avatar.background.itemId : 4167;
				if (backgroundId != _avatarBackgroundId)
				{
					var backgroundUrl:String = ItemUtil.GetPreviewUrl(backgroundId);
					_avatarBackgroundId = backgroundId;
					backgroundLoader = new QuickLoader(backgroundUrl, onBackgroundComplete);
				}
				else
				{
					compositeImage();
				}
			}
			
			function onBackgroundComplete():void
			{
				_avatarBackground = backgroundLoader.content;
				compositeImage();
			}
			
			function compositeImage():void
			{
				// Composite avatar image and background together.
				// Also composite avatar stylizing.
				var background:Sprite = new Sprite();
				background.addChild(_avatarBackground);
				avatarImage.filters = AvatarSprite.DefaultAvatarPreviewFilters;
				avatarImage.x = background.width / 2 - avatarImage.width / 2;
				avatarImage.y = background.height / 2 - avatarImage.height / 2;
				var bitmapData:BitmapData = new BitmapData(background.width, background.height);
				background.addChild(avatarImage);
				bitmapData.draw(background);
				var compositeImage:Bitmap = new Bitmap(bitmapData, 'auto', true);
				var image:Sprite = new Sprite();
				image.addChild(compositeImage);
				
				// Pass avatar info into avatar info panel.
				if(_avInfoPanel)
				{
					_avInfoPanel.setImage(image);
				
					// Now that the avatar is done "changing clothes", uncover the avatar image.
					_avInfoPanel.unCoverImage();
				}
			}
		}
		
	}
}
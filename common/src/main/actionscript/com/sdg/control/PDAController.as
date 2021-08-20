package com.sdg.control
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.CardAlbum;
	import com.sdg.components.dialog.ModeratorBehaviorDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.dialog.helpers.MainDialogHelper;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.AvatarApparelSaveEvent;
	import com.sdg.events.AvatarEvent;
	import com.sdg.events.InventoryListEvent;
	import com.sdg.events.ModeratorSaveReportEvent;
	import com.sdg.events.PDACallEvent;
	import com.sdg.events.PDACallPanelEvent;
	import com.sdg.events.PickemScorecardEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.manager.BadgeManager;
	import com.sdg.manager.SoundManager;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarReciever;
	import com.sdg.model.Badge;
	import com.sdg.model.BadgeCategoryCollection;
	import com.sdg.model.BadgeCollection;
	import com.sdg.model.BadgeLevelCollection;
	import com.sdg.model.GameAssetId;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.PDACallModel;
	import com.sdg.model.Server;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	import com.sdg.utils.PreviewUtil;
	import com.sdg.utils.StoreTrackingUtil;
	import com.sdg.view.IRoomView;
	import com.sdg.view.pda.AvatarCardPanel;
	import com.sdg.view.pda.BadgesPanel;
	import com.sdg.view.pda.BuddyCardPanel;
	import com.sdg.view.pda.CustomizerPanel;
	import com.sdg.view.pda.FeedbackPanel;
	import com.sdg.view.pda.FriendsPanel;
	import com.sdg.view.pda.GamesPanel;
	import com.sdg.view.pda.MainMenuPanel;
	import com.sdg.view.pda.MessagesPanel;
	import com.sdg.view.pda.MyStatsPanel;
	import com.sdg.view.pda.PDACallPanel;
	import com.sdg.view.pda.PDAView;
	import com.sdg.view.pda.PickemPanel;
	import com.sdg.view.pda.PickemScorecardData;
	import com.sdg.view.pda.QuestApplication;
	import com.sdg.view.pda.interfaces.IPDAMainPanel;
	import com.sdg.view.pda.interfaces.IPDAView;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;

	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.events.EffectEvent;

	[Bindable]
	public class PDAController extends EventDispatcher
	{
		public static const SHOW_PDA:String = 'show pda';
		public static const HIDE_PDA:String = 'hide pda';
		public static const AVATAR_UPDATE:String = 'avatar update';

		public static var SaveAvatarApparelEnabled:Boolean = true;

		private static var _instance:PDAController;

		private var _isShown:Boolean = false;
		private static var _pdaButton:Sprite;
		private var _pdaView:IPDAView;
		private var _roomView:IRoomView;
		private var _animationManager:AnimationManager = new AnimationManager();
		private var _incomingCall:Boolean;

		public var inventoryItems:ArrayCollection;
		public var inventoryGames:ArrayCollection;
		public var pickemData:PickemScorecardData = new PickemScorecardData;

		public var jabCount:int = 2;
		public var hudcontroller:HudController = HudController.getInstance();

		private var _buddyCardPanel:BuddyCardPanel;
		private var _customizerPanel:CustomizerPanel;
		private var _gamesPanel:GamesPanel;
		private var _mainMenuPanel:MainMenuPanel;
		private var _avatarCardPanel:AvatarCardPanel;
		private var _mouseOverSound:Sound;
		private var _clickSound:Sound;
		private static var _buttonAbstarct:Object;
		private static var _quedPhoneCall:PDACallModel;
		private static var _hasBeenShownBefore:Boolean = false;
		protected var _avatar:Avatar;
		private static const _tokenObj:Object = {name: 'PDAController'};

		/**
		 * Constructor.
		 */
		public function PDAController()
		{
			var button:QuickLoader;

			if (!_instance)
			{
				super();
				_pdaView = new PDAView(this);
				_incomingCall = false;
				loadSounds();
				_pdaButton = new Sprite();
				_pdaButton.addEventListener(MouseEvent.CLICK, onPdaButtonClick);
				_pdaButton.addEventListener(MouseEvent.ROLL_OVER, onPdaButtonOver);
				loadPdaButton();
				_avatar = ModelLocator.getInstance().avatar;

				// Listen for room join.
				RoomManager.getInstance().socketMethods.addEventListener('joinRoomSuccess', onJoinRoomSuccess);

				_pdaView.view.addEventListener(PDAView.OUTSIDE_CLICK, onPdaViewOutsideClick);
			}
			else
				throw new Error("PDAController is a singleton class. Use 'getInstance()' to access the instance.");
		}

		public static function getInstance():PDAController
		{
			if (_instance == null)
				_instance = new PDAController();
			return _instance;
		}

		////////////////////
		// PUBLIC METHODS
		////////////////////

		public function showPDA():void
		{
			if (_isShown == true) return;

			// Dispatch an event to signify
			// that the PDA has been shown.
			_instance.dispatchEvent(new Event(SHOW_PDA));

			// Show the PDA view.
			// If the PDA hasn't been shown for the first time,
			// DON'T use an animation to show it.
			if (_hasBeenShownBefore != true)
			{
				_pdaView.visible = true;
				_roomView.addPopUp(_pdaView.view);
				_hasBeenShownBefore = true;
			}
			else
			{
				// Make it scale up from the bottom right.
				_pdaView.view.alpha = 0;
				_pdaView.visible = true;
				var newX:Number = 0;
				var newY:Number = 0;
				_pdaView.view.scaleX = _pdaView.view.scaleY = 0;
				_roomView.addPopUp(_pdaView.view);
				_pdaView.x = 925;
				_pdaView.y = 665;
				var duration:uint = 300;
				_animationManager.alpha(_pdaView.view, 1, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				_animationManager.scale(_pdaView.view, 1, 1, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				_animationManager.move(_pdaView.view, newX, newY, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			}

			// Play a sound.
			var soundUrl:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD_SOUND, 'pda_open.mp3');
			SoundManager.GetInstance().playSound(soundUrl);

			// Set flag.
			_isShown = true;

			// Send pda button to the in-use state.
			if (_buttonAbstarct != null) _buttonAbstarct.inUse();
		}

		public function hidePDA(event:Event = null):void
		{
			if (_isShown == false) return;

			// Animate the pda into the lower right corner.
			var duration:uint = 300;
			_animationManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animationManager.alpha(_pdaView.view, 0, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animationManager.move(_pdaView.view, 925, 665, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animationManager.scale(_pdaView.view, 0, 0, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);

			// Play a sound.
			var soundUrl:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD_SOUND, 'pda_close.mp3');
			SoundManager.GetInstance().playSound(soundUrl);

			// Send pda button to the default state.
			if (_buttonAbstarct != null) _buttonAbstarct.setDefault();

			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;
			if (mainPanel)
				mainPanel.close();

			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget != _pdaView.view) return;
				// Remove event listener.
				_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);

				// Make PDA view invisible.
				_pdaView.visible = false;

				// Remove the pda view pop up.
				_roomView.removePopUp(_pdaView.view);

				// Set flag.
				_isShown = false;

				// Dispatch a hide event.
				dispatchEvent(new Event(HIDE_PDA));
			}
		}

		public function getScorecard():void
		{
			CairngormEventDispatcher.getInstance().addEventListener(PickemScorecardEvent.SCORECARD_RECEIVED, onScorecardReceived);
			CairngormEventDispatcher.getInstance().dispatchEvent(new PickemScorecardEvent(avatar.avatarId));
		}

		public function submitComment(comment:String):void
		{
			var params:Object = {
				reportTypeId:10,
				reporterId:avatar.avatarId,
				subReason:comment,
				roomId:String(RoomManager.getInstance().currentRoomId),
				serverId:String(Server.getCurrentId())
			};

			CairngormEventDispatcher.getInstance().dispatchEvent(new ModeratorSaveReportEvent(params));
		}

		public function openCustomizer():void
		{
			if (_customizerPanel == null) _customizerPanel = new CustomizerPanel();

			// Determine if we need to update the user's avatar.
			var doesNeedUpdate:Boolean = _avatar.getDoesNeedUpdate(_tokenObj);
			if (doesNeedUpdate)
			{
				// Update avatar.
				addEventListener(AVATAR_UPDATE, onAvatarUpdate);
				updateAvatar();
			}
			else
			{
				sendPanel();
			}

			function onAvatarUpdate(e:Event):void
			{
				removeEventListener(AVATAR_UPDATE, onAvatarUpdate);

				sendPanel();
			}

			function sendPanel():void
			{
				_pdaView.mainPanel = _customizerPanel;
			}
		}

		public function openLeaderboard():void
		{
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			// Rotate the PDA 90 degrees and open the leader board.


			_pdaView.mainScreen.mouseChildren = false;
			_pdaView.rotatePDA(onPDARotate);

			function onPDARotate(event:EffectEvent):void
			{
				event.currentTarget.removeEventListener(EffectEvent.EFFECT_END, onPDARotate);

				AASModuleLoader.openLeaderBoard();
				Application.application.addEventListener("closeModule", onModuleClose);
			}

			function onModuleClose(e:Event):void
			{
				Application.application.removeEventListener('closeModule', onModuleClose);

				// Rotate the PDA back to it's original position.
				_pdaView.rotatePDA(null, 90, 0, 100);
				_pdaView.mainScreen.mouseChildren = true;
			}
		}

		public function openGamesPanel():void
		{
			if (_gamesPanel == null) _gamesPanel = new GamesPanel();

			_pdaView.mainPanel = _gamesPanel;
		}

		public function openPickemPanel():void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is PickemPanel))
				mainPanel = new PickemPanel();

			_pdaView.mainPanel = mainPanel;
		}

		public function openMessagesPanel():void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is MessagesPanel))
				mainPanel = new MessagesPanel();

			_pdaView.mainPanel = mainPanel;
		}

		public function openMyStatsPanel():void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is MyStatsPanel))
				mainPanel = new MyStatsPanel();

			_pdaView.mainPanel = mainPanel;
		}

		public function openQuestsPanel():void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is QuestApplication))
				mainPanel = new QuestApplication();

			_pdaView.mainPanel = mainPanel;
		}

		public function openFeedbackPanel():void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is FeedbackPanel))
				mainPanel = new FeedbackPanel();

			_pdaView.mainPanel = mainPanel;
		}

		public function openBuddyCardPanel(buddyAvatar:Avatar):void
		{
			// Make sure the user is registered.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
			}

			if (_buddyCardPanel == null) _buddyCardPanel = new BuddyCardPanel();

			// Determine if the avatar needs to be updated.
			if (buddyAvatar.getDoesNeedUpdate(_tokenObj))
			{
				// Load avatar data from the server.
				_buddyCardPanel.addEventListener(BuddyCardPanel.AVATAR_SET, onAvatarSet);
				CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarEvent(buddyAvatar.avatarId, _buddyCardPanel));
			}
			else
			{
				// Set avatar on buddy card.
				if (_buddyCardPanel.avatar == null || buddyAvatar.avatarId != _buddyCardPanel.avatar.avatarId)
					_buddyCardPanel.avatar = buddyAvatar;
				showPanel();
			}

			function onAvatarSet(e:Event):void
			{
				// Remove listener.
				_buddyCardPanel.removeEventListener(BuddyCardPanel.AVATAR_SET, onAvatarSet);

				// This avatar does not need to be updated,
				// unless some of it's pertinent properties change.
				buddyAvatar.setDoesNotNeedUpdate(_tokenObj);

				showPanel();
			}

			function showPanel():void
			{
				_pdaView.mainPanel = _buddyCardPanel;
			}
		}

		public function openStore():void
		{
			// Make sure the user is registered.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}

			// Rotate the PDA 90 degrees and open the store catalog.

			_pdaView.mainScreen.mouseChildren = false;
			_pdaView.rotatePDA(onPDARotate);
			StoreTrackingUtil.trackButtonClick(StoreTrackingUtil.PDA_CATALOG);

			function onPDARotate(event:EffectEvent):void
			{
				event.currentTarget.removeEventListener(EffectEvent.EFFECT_END, onPDARotate);

				AASModuleLoader.openStoreModule(null, "StoreCatalogModule", 'Store', true);
				Application.application.addEventListener('closeModule', onStoreClose);
			}

			function onStoreClose(e:Event):void
			{
				Application.application.removeEventListener('closeModule', onStoreClose);
				_pdaView.rotatePDA(null, 90, 0, 100);
				_pdaView.mainScreen.mouseChildren = true;
			}
		}

		public function showPhoneCall(callData:PDACallModel):void
		{
			_pdaView.mainPanel = new PDACallPanel(callData);
		}

		public function showMainMenu():void
		{
			if (_mainMenuPanel == null) _mainMenuPanel = new MainMenuPanel();

			_pdaView.mainPanel = _mainMenuPanel;
		}

		public function showNews():void
		{
			ModelLocator.getInstance().avatar.dispatchEvent(new Event('Event_ASN_Shown'));
			MainDialogHelper.showDialog({news:true});
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>4</uiId></uiEvent>" });
		}

		public function showFriendsList():void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is FriendsPanel))
				mainPanel = new FriendsPanel();

			_pdaView.mainPanel = mainPanel;
		}

		public function showBadgeList():void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is BadgesPanel))
			{
				if (BadgeManager.BadgesAvailable == false)
				{
					var isBadgesLoaded:Boolean = false;
					BadgeManager.Instance.addEventListener(BadgeManager.BADGE_LOAD_COMPLETE, onComplete);
					BadgeManager.LoadBadges();
				}
				else
				{
					mainPanel = new BadgesPanel();
					_pdaView.mainPanel = mainPanel;
				}
			}
			else
			{
				_pdaView.mainPanel = mainPanel;
			}

			function onComplete(event:Event):void
			{
				if (isBadgesLoaded == false)
				{
					isBadgesLoaded = true;
					BadgeManager.LoadAvatarBadges(avatar.avatarId);
				}
				else
				{
					BadgeManager.Instance.removeEventListener(BadgeManager.BADGE_LOAD_COMPLETE, onComplete);
					var bPanel:BadgesPanel = new BadgesPanel();
					_pdaView.mainPanel = bPanel;
				}

//				for (var i:int = 0; i < badges.length; i++)
//				{
//					var badge:Badge = badges.getAt(i);
//					trace(badge.name);
//					badgesList.addItem(badge);
////					var badgeLevels:BadgeLevelCollection = badge.levels;
//					for (var j:int = 0; j < badgeLevels.length; j++)
//					{
//						trace("\t" + badgeLevels.getAt(j).name);
//					}
//				}
			}
		}

		public function showBadgeListAtBadge(badgeId:int):void
		{
			var mainPanel:IPDAMainPanel = _pdaView.mainPanel;

			if (!(mainPanel is BadgesPanel))
			{
				if (BadgeManager.BadgesAvailable == false)
				{
					var isBadgesLoaded:Boolean = false;
					BadgeManager.Instance.addEventListener(BadgeManager.BADGE_LOAD_COMPLETE, onComplete);
					BadgeManager.LoadBadges();
				}
				else
				{
					mainPanel = new BadgesPanel();
					_pdaView.mainPanel = mainPanel;
				}
			}
			else
			{
				_pdaView.mainPanel = mainPanel;
			}

			function onComplete(event:Event):void
			{
				if (isBadgesLoaded == false)
				{
					isBadgesLoaded = true;
					BadgeManager.LoadAvatarBadges(avatar.avatarId);
				}
				else
				{
					BadgeManager.Instance.removeEventListener(BadgeManager.BADGE_LOAD_COMPLETE, onComplete);
					var params:Object = new Object();
					params.initBadgeId = badgeId;
					var bPanel:BadgesPanel = new BadgesPanel();
					_pdaView.mainPanel = bPanel;
				}

			}
		}

		public function showCardAlbum():void
		{
			if (avatar.membershipStatus == 3)
				//MainUtil.showDialog(MonthFreeUpsellDialog, {showPremiumHeader:false, messaging:"This feature is only available if you register."});
				MainUtil.showDialog(SaveYourGameDialog);
			else
				MainUtil.showDialog(CardAlbum);
		}

		public function getBadgeCategories():BadgeCategoryCollection
		{
			return BadgeManager.BadgeCategories;
		}

		public function getBadgeAlphabetical():ArrayCollection
		{
			return new ArrayCollection(BadgeManager.AllBadges.toArray());
		}

		public function getBadgesAlphaFiltered():ArrayCollection
		{
			var output:Array = new Array();
			var bc:BadgeCollection = BadgeManager.AllBadges;
			for (var i:int = 0; i < bc.length;i++)
			{
				var b:Badge = bc.getAt(i);
				//var lev:BadgeLevelCollection = b.levels;
				if (!BadgeManager.DoesAvatarOwnBadge(ModelLocator.getInstance().avatar.avatarId, b.id))
				{
					if ((b.id == 31)||(b.id == 32)||(b.id == 33)||(b.id == 37)||(b.id == 38)||(b.id == 39)||(b.id == 40))
					{
						// do nothing
					}
					else
					{
						output.push(b);
					}
				}
				else
				{
					output.push(b);
				}
			}

			return new ArrayCollection(output);
		}

		public function getBadgesByCategory(categoryId:uint):ArrayCollection
		{
			return new ArrayCollection(BadgeManager.GetBadgesByCategory(categoryId).toArray());
		}

		public function saveAvatar():void
		{
			// Make sure saving is enabled.
			if (!SaveAvatarApparelEnabled) return;
			CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarApparelSaveEvent(avatar));
		}

		public function getInventoryType(itemTypeId:int):void
		{
			CairngormEventDispatcher.getInstance().addEventListener(InventoryListEvent.LIST_COMPLETED, onInventoryListCompleted);
			CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(avatar.avatarId, itemTypeId));
		}

		public function isIgnored(selectedAvatar:Avatar):Boolean
		{
			return ModelLocator.getInstance().ignoredAvatars[selectedAvatar.avatarId];
		}

		public function toggleIgnore(selectedAvatar:Avatar):void
		{
			// get the ignored state
			var isIgnored:Boolean = isIgnored(selectedAvatar);

			// toggle it
			ModelLocator.getInstance().ignoredAvatars[selectedAvatar.avatarId] = !isIgnored;

			// log this action
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "ignore", { ignoredAvatarId:selectedAvatar.avatarId, ignoreStatus:isIgnored ? 1 : 0 });
		}

		public function reportToModerator(accusedAvatar:Avatar):void
		{
			MainUtil.showDialog(ModeratorBehaviorDialog, {accused:accusedAvatar});
		}

		public function gotoBuddyHome(buddyAvatar:Avatar):void
		{
			RoomManager.getInstance().homeTurfAvatar = buddyAvatar;
			// goto the private room of this avatar
			CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, buddyAvatar.privateRoom));

			hidePDA();
		}

		public function addRemoveBuddy(buddyAvatar:Avatar, avatarIsBuddy:Boolean):void
		{
			// if the avatar is not already a buddy call buddyRequest, otherwise call buddyRemove
			if (!avatarIsBuddy)
			{
				// if you are a guest
				if (avatar.membershipStatus == 3)
				{
					//upsell
					//MainUtil.showDialog(MonthFreeUpsellDialog, {showPremiumHeader:false, messaging:"This feature is only available if you register."});
					MainUtil.showDialog(SaveYourGameDialog);
					return;
				}
				// if buddy is a guest
				else if (buddyAvatar.membershipStatus == 3)
				{
					// cant buddy a guest
					SdgAlertChrome.show("Oops! " + buddyAvatar.name + " is unable to send or accept buddy requests as a Guest Member.", "Time Out!");
					return;
				}
				BuddyManager.makeBuddyRequest(buddyAvatar.avatarId, buddyAvatar.name);
			}
			else
				BuddyManager.makeRemoveBuddyRequest(buddyAvatar.avatarId);
				//SocketClient.sendMessage("avatar_handler", "buddyRemove", "buddy", { avatarId:avatar.avatarId, buddyAvatarId:buddyAvatar.avatarId, friendTypeId:1, statusId:2 } );

			//hidePDA();
		}

		public function equipBadge(badgeId:int, badgeName:String, levelId:int, levelName:String, levelValue:int):void
		{
			if (BadgeManager.DoesAvatarOwnBadgeLevel(avatar.avatarId, badgeId, levelId))
			{
				var message:String = badgeId + "|" + badgeName + "|" + levelId + "|" + levelName + "|" + levelValue;
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "equipBadge", { equipBadge:message });
			}
		}

		public function showAvatar(avatar:Avatar):void
		{
			// Setup avatar view on the pda.
			if (ModelLocator.getInstance().avatar.avatarId == avatar.avatarId)
			{
				// Show the user's avatar.
				openCustomizer();
			}
			else
			{
				// Show some other players avatar.
				openBuddyCardPanel(avatar);
			}

			// Show the pda.
			showPDA();
		}

		public function stopRing():void
		{
			if (_buttonAbstarct) _buttonAbstarct.setDefault();
			dispatchEvent(new Event(HIDE_PDA));
		}

		public function newPhoneCall(callData:PDACallModel):void
		{
			if (Constants.PDA_ENABLED != true) return;

			// Make sure there is not already a call in progress.
			if (_incomingCall == true) return;

			// Make sure the button is ready.
			if (_buttonAbstarct == null)
			{
				// Que the call.
				_quedPhoneCall = callData;
				return;
			}

			// Remove current pda click handler.
			_pdaButton.removeEventListener(MouseEvent.CLICK, onPdaButtonClick);

			// Set flag.
			_incomingCall = true;

			// Create local flag.
			var callAnswered:Boolean = false;

			// Show the PDA.
			showPDA();

			// Show a phone call on the main screen.
			showPhoneCall(callData);

			// Listen for when to answer the call.
			_pdaView.mainScreen.addEventListener(PDACallPanelEvent.ANSWER_CLICK, onAnswerClick);

			// Listen for hide.
			addEventListener(HIDE_PDA, onHide);

			// Send pda button to calling state.
			_buttonAbstarct.ring();

			function onAnswerClick(e:PDACallPanelEvent):void
			{
				// Set flag.
				callAnswered = true;
				_quedPhoneCall = null;

				// Dispatch an event to signify that the call has been answered.
				var event:PDACallEvent = new PDACallEvent(PDACallEvent.CALL_ANSWERED, callData);
				dispatchEvent(event);

				finish();
			}

			function onHide(e:Event):void
			{
				// Que the call for later.
				_quedPhoneCall = callData;

				finish();
			}

			function finish():void
			{
				// Remove listener.
				_pdaView.mainScreen.removeEventListener(PDACallPanelEvent.ANSWER_CLICK, onAnswerClick);
				removeEventListener(HIDE_PDA, onHide);

				// Add the original button click listener.
				_pdaButton.addEventListener(MouseEvent.CLICK, onPdaButtonClick);

				// Set flag.
				_incomingCall = false;

				// Send pda button to default state.
				_buttonAbstarct.setDefault();

				// Send the PDA to the main menu and hide it.
				showMainMenu();
			}
		}

		public function handleQuedCalls():void
		{
			if (_quedPhoneCall != null) _instance.newPhoneCall(_quedPhoneCall);
		}

		public function updateAvatar():void
		{
			var avatarReciever:AvatarReciever = new AvatarReciever();
			avatarReciever.addEventListener(AvatarReciever.AVATAR_SET, onAvatarSet);
			CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarEvent(_avatar.avatarId, avatarReciever, _avatar));

			function onAvatarSet(e:Event):void
			{
				// Remove listener.
				avatarReciever.removeEventListener(AvatarReciever.AVATAR_SET, onAvatarSet);

				_avatar = avatarReciever.avatar;

				// This avatar does not need to be updated,
				// unless some of it's pertinent properties change.
				_avatar.setDoesNotNeedUpdate(_tokenObj);

				dispatchEvent(new Event(AVATAR_UPDATE));
			}
		}

		////////////////////
		// PRIVATE METHODS
		////////////////////

		private function calcPercent(answerCount:Object):Array
		{
			var total:int = 0;
			for each (var count:int in answerCount)
				total += count;

			var percentages:Array = [];
			for each (var choice:int in answerCount)
			{
				if (total != 0)
					percentages.push(Math.round((choice/total) * 100));
				else
					percentages.push(0);
			}
			return percentages;
		}

		private function onScorecardReceived(event:PickemScorecardEvent):void
		{
			pickemData.pickemPicks.removeAll();
			pickemData.status = event.params.questions.@status;

			var largestEventId:int = 0;
			for each (var question:XML in event.params.questions.question)
			{
				if (question.@eventId >= largestEventId)
				{
					if (question.@eventId > largestEventId)
					{
						pickemData.pickemPicks.removeAll();
						largestEventId = question.@eventId;
						pickemData.numCorrect = 0;
					}

					var pick:Object = {};
					pickemData.pickemPicks.addItem(pick);

					pick.selected = -1;
					pick.correct = -1;
					pick.images = {};
					pick.answer = {};
					pick.answerCount = {};
					pick.isCorrect = false;
					pick.status = pickemData.status;

					for (var i:int = 0; i < question.children().length(); i++)
					{
						if (question.answer[i].@selected == 1)
							pick.selected += i + 1;

						if (question.answer[i].@correct == 1)
							pick.correct += i + 1;

						var imageUrl:String = Environment.getApplicationUrl() + "/test/static/clipart/";

						if ("@teamid" in question.answer[i])
							pick.images[i] = imageUrl + "teamLogoTemplate?teamId=" + question.answer[i].@teamid;
						else if ("@playerid" in question.answer[i])
							pick.images[i] = imageUrl + "playerLogoTemplate?playerId=" + question.answer[i].@playerid;

						pick.answer[i] = question.answer[i];
						pick.answerCount[i] = question.answer[i].@answerCount;
					}

					pick.question = question.@text;
					pick.percentages = calcPercent(pick.answerCount);

					if (pick.correct == pick.selected || pick.correct > 1)
					{
						pick.isCorrect = true;
						pickemData.numCorrect++;
					}
				}
			}
			dispatchEvent(new Event("pickemDataComplete"));
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "quizGameComplete", { numCorrect:pickemData.numCorrect, gameTypeId:2 });

		}

		private function onBoardClose(e:Event):void
		{
			Application.application.removeEventListener(Event.CLOSE,onBoardClose);
			this.showPDA();
		}

		private function loadSounds():void
		{
			// Get ready to load this sound.
			var gameId:String = '99';
			var assetPath:String = Environment.getAssetUrl() + '/test/gameSwf/gameId/' + gameId + '/gameFile/';
			var mouseOverSoundRequest:URLRequest = new URLRequest(assetPath + 'Click075.mp3');
			var clickSoundRequest:URLRequest = new URLRequest(assetPath + 'Click076.mp3');

			_mouseOverSound = new Sound();
			_clickSound = new Sound();

			// Do the load.
			_mouseOverSound.load(mouseOverSoundRequest);
			_mouseOverSound.addEventListener(Event.COMPLETE, onComplete);
			_mouseOverSound.addEventListener(IOErrorEvent.IO_ERROR, onMouseOverIOError);
			_clickSound.load(clickSoundRequest);
			_clickSound.addEventListener(Event.COMPLETE, onComplete);
			_clickSound.addEventListener(IOErrorEvent.IO_ERROR, onClickIOError);

			function onComplete(event:Event):void
			{
				event.currentTarget.removeEventListener(Event.COMPLETE, onComplete);
				event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}

			function onMouseOverIOError(event:IOErrorEvent):void
			{
				onIOError(event);
				_mouseOverSound = null;
			}
			function onClickIOError(event:IOErrorEvent):void
			{
				onIOError(event);
				_clickSound = null;
			}

			function onIOError(event:IOErrorEvent):void
			{
				event.currentTarget.removeEventListener(Event.COMPLETE, onComplete);
				event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}

		private static function loadPdaButton():void
		{
			var maxTry:uint = 3;
			var tries:uint = 0;
			var url:String = "swfs/pda/pdaLauncher.swf";
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);

			function onError(e:Event):void
			{
				if (tries < maxTry)
				{
					tries++;
					loader.load(request);
				}
				else
				{
					// Remove listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				}
			}

			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);

				_pdaButton.addChild(loader.content);
				_buttonAbstarct = loader.content as Object;

				// If there is a qued call, handle it.
				_instance.handleQuedCalls();
			}
		}

		private function onInventoryListCompleted(event:InventoryListEvent):void
		{
			if (avatar.membershipStatus == 0)
        	{
        		for each (var item:InventoryItem in avatar.getInventoryListById(event.itemTypeId))
        		{
        			if (item.itemValueType == InventoryItem.PREMIUM)
        			{
        				item.isGreyedOut = true;
        			}
        		}
        	}

        	// gather our headwear
			switch (event.itemTypeId)
			{
				case PreviewUtil.HAT:
					inventoryItems = new ArrayCollection(avatar.getInventoryListById(PreviewUtil.HAT).source);
					CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(avatar.avatarId, PreviewUtil.BEANIE));
					break;
				case PreviewUtil.BEANIE:
					inventoryItems.source = inventoryItems.source.concat(avatar.getInventoryListById(PreviewUtil.BEANIE).source);
					CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(avatar.avatarId, PreviewUtil.HEADBAND));
					break;
				case PreviewUtil.HEADBAND:
					inventoryItems.source = inventoryItems.source.concat(avatar.getInventoryListById(PreviewUtil.HEADBAND).source);
					CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(avatar.avatarId, PreviewUtil.VISOR));
					break;
				case PreviewUtil.VISOR:
					inventoryItems.source = inventoryItems.source.concat(avatar.getInventoryListById(PreviewUtil.VISOR).source);
					CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(avatar.avatarId, PreviewUtil.HELMET));
					break;
				case PreviewUtil.HELMET:
					CairngormEventDispatcher.getInstance().removeEventListener(InventoryListEvent.LIST_COMPLETED, onInventoryListCompleted);
					inventoryItems.source = inventoryItems.source.concat(avatar.getInventoryListById(PreviewUtil.HELMET).source);
					break;
				case PreviewUtil.BOARD_GAME:
					CairngormEventDispatcher.getInstance().removeEventListener(InventoryListEvent.LIST_COMPLETED, onInventoryListCompleted);
					inventoryGames = avatar.getInventoryListById(event.itemTypeId);
					break;
				default:
					// this is non-headwear
					CairngormEventDispatcher.getInstance().removeEventListener(InventoryListEvent.LIST_COMPLETED, onInventoryListCompleted);
					inventoryItems = avatar.getInventoryListById(event.itemTypeId);
					break;
			}
		}

		private function setPDAButtonPulse(value:Boolean):void
		{
			if (_buttonAbstarct != null) _buttonAbstarct.pulse = value;
		}

		////////////////////
		// GET/SET METHODS
		////////////////////

		public function get pdaView():IPDAView
		{
			return _pdaView;
		}
		public function set pdaView(value:IPDAView):void
		{
			if (value == _pdaView) return;

			// Set new pda view.
			_pdaView = value;
		}

		public function get roomView():IRoomView
		{
			return _roomView;
		}
		public function set roomView(value:IRoomView):void
		{
			if (value == _roomView) return;

			_roomView = value;



			//_roomView.addPopUp(_pdaView.view);
			//hidePDA();
		}

		public function get avatarCardPanel():AvatarCardPanel
		{
			if (_avatarCardPanel == null) _avatarCardPanel = new AvatarCardPanel();
			return _avatarCardPanel;
		}

		public function get animationManager():AnimationManager
		{
			return _animationManager;
		}

		public function get button():Sprite
		{
			return _pdaButton;
		}

		public function get mouseOverSound():Sound
		{
			return _mouseOverSound;
		}

		public function get clickSound():Sound
		{
			return _clickSound;
		}

		public function isBuddy(avatarId:int):Boolean
		{
			return BuddyManager.isBuddy(avatarId);
		}

		public function get isShown():Boolean
		{
			return _isShown;
		}

		public function get avatar():Avatar
		{
			return _avatar;
		}

		public function get mainMenu():MainMenuPanel
		{
			return _mainMenuPanel;
		}

		////////////////////
		// EVENT HANDLERS
		////////////////////

		private function onPdaButtonClick(e:MouseEvent):void
		{
			// Either show or hide the pda.
			if (_isShown == true)
			{
				hidePDA();
			}
			else
			{
				// Setup the PDA home screen.
				showMainMenu();

				// Show the PDA.
				showPDA();
			}

			// Play a sound.
			var soundUrl:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD_SOUND, 'pda_button_click.mp3');
			SoundManager.GetInstance().playSound(soundUrl);
		}

		private function onPdaButtonOver(e:MouseEvent):void
		{
			// Play a sound.
			var soundUrl:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD_SOUND, 'generic_roll_over_03.mp3');
			SoundManager.GetInstance().playSound(soundUrl);
		}

		private static function onJoinRoomSuccess(e:SocketRoomEvent):void
		{
			_instance.handleQuedCalls();
		}

		private static function onPdaViewOutsideClick(e:Event):void
		{
			// If the user clicks anywhere outside of the PDA, hide the PDA.
			_instance.hidePDA();
		}

	}
}

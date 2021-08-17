package com.sdg.control.game
{
	import com.sdg.animation.AnimationSet;
	import com.sdg.animation.AnimationSetResource;
	import com.sdg.animation.sequence.ISequence;
	import com.sdg.business.resource.RemoteResourceMap;
	import com.sdg.business.resource.SdgResourceLocator;
	import com.sdg.components.controls.GameConsole;
	import com.sdg.components.controls.GameConsoleDelegate;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.PDAController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.RoomUIController;
	import com.sdg.control.room.itemClasses.AvatarController;
	import com.sdg.control.room.itemClasses.Character;
	import com.sdg.control.room.itemClasses.IRoomItemController;
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.core.StageProxy;
	import com.sdg.display.AvatarSprite;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.SpriteSheet;
	import com.sdg.events.GamePlaceChangeEvent;
	import com.sdg.events.RoomEnumEvent;
	import com.sdg.events.SimEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.game.counter.GamePlayCounter;
	import com.sdg.game.keycombo.IKeyComboController;
	import com.sdg.game.keycombo.KeyCombo;
	import com.sdg.game.keycombo.KeyComboEvent;
	import com.sdg.game.keycombo.KeyComboMap;
	import com.sdg.model.Avatar;
	import com.sdg.model.GameAssetId;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.PrizeItem;
	import com.sdg.model.Reward;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItem;
	import com.sdg.model.SdgItemAssetType;
	import com.sdg.model.SdgItemClassId;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.RemoteSoundBank;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.pet.PetManager;
	import com.sdg.sim.entity.TileMapEntity;
	import com.sdg.skate.ISkateGameUI;
	import com.sdg.skate.SkateGameUI;
	import com.sdg.skate.SkateTrickEvent;
	import com.sdg.util.AssetUtil;
	import com.sdg.util.Delay;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import modules.RoomModule; // Non-SDG

	public class SkateboardGameController extends RoomUIController
	{
		[Embed(source='images/skate/skater_game_body_big.png')]
		private static const SkaterBodySpriteSheet:Class;

		[Embed(source='images/skate/skater_game_clothes_big.png')]
		private static const SkaterClothesSpriteSheet:Class;

		[Embed(source='images/skate/skater_game_girl_hair_big.png')]
		private static const SkaterGirlHairSpriteSheet:Class;

		[Embed(source='swfs/skate/skate_freeze_cube.swf')]
		private static const FreezeGraphic:Class;

		[Embed(source='swfs/skate/this_is_you_effect.swf')]
		private static const ThisIsYouGraphic:Class;

		[Embed(source="audio/skate_error.mp3")]
		private static var SkateErrorSound:Class;

		[Embed(source="audio/ding.mp3")]
		private static var DingSound:Class;

		[Embed(source="audio/skate_snap.mp3")]
		private static var SkateSnap:Class;

		[Embed(source="audio/skate_roll.mp3")]
		private static var SkateRoll:Class;

		[Embed(source="audio/skate_roll_loop.mp3")]
		private static var SkateRollLoop:Class;

		[Embed(source="audio/skate_stop.mp3")]
		private static var SkateStop:Class;

		protected static const DEFAULT_GAME_ASSET_ID:int = 67;

		private static const _USE_HIGH_RES_SCORING:Boolean = true; // Whether to use combo accuracy to calculate score.
		private static const _SCORE_PERCENT_RISKED_ON_ACCURACY:Number = 0.25; // Amount of base trick score to risk towards accuracy.
		private static const _SKATER_ANIM_SET_ID:int = 211;
		private static const _SKATE_ROLL_VOLUME:Number = 0.03;
		private static const _DEFAULT_TRICK_DURATION:int = 400;
		private static const _INVALID_COMBO_TRICK_ID:int = 101;
		private static const _MISTIMED_TRICK_ID:int = 102;

		protected var _uiView:ISkateGameUI;
		protected var _scoreTricks:Boolean;
		protected var _allowKeyCombo:Boolean;
		protected var _soundBank:RemoteSoundBank;
		protected var _postTrickDelay:int;
		protected var _gameId:int;

		private var _currentKeyCombo:IKeyComboController;
		private var _currentComboComplete:Boolean;
		private var _keyComboMap:KeyComboMap;
		private var _isThereCurrentCombo:Boolean;
		private var _skaterAnimSet:AnimationSet;
		private var _localSkaterSoundChannel:SoundChannel;
		private var _isLocalSkaterRolling:Boolean;
		private var _skateRollLoop:SoundChannel;
		private var _skateRollLoopUpdateTimer:Timer;
		private var _isLocalSkaterMidTrick:Boolean;
		private var _allowLocalSkaterMove:Boolean;
		private var _crowdSoundChannel:SoundChannel;
		private var _cheerSoundUrls:Array;
		private var _lastPlayedCheerIndex:int; // So we dont play the same one twice.
		private var _totalTricksByLocalUser:int;
		private var _trickTally:Array;
		private var _avatarLabels:Array;
		private var _gameLength:int;
		private var _gameLaunchTime:int;
		private var _preScoringPeriodLength:int;
		private var _postScoringPeriodLength:int;
		private var _gameTimeCheckTimer:Timer;
		private var _avatarColors:Array;
		private var _defaultAvatarColor:uint;
		private var _avatarNames:Array;
		private var _trickMessaging:Boolean;
		private var _timerToCountdownStarted:Boolean;
		private var _lastPlayedTrickSoundUrl:String;
		private var _itemsInRoom:Array;
		private var _itemsInEffect:Array;
		private var _pickUpItemTypeAvatarFilters:Array;
		private var _localPointMultiplier:Number;
		private var _localAvatarBaselineFilters:Array;
		private var _pickUpMessageSentToServer:Array;
		private var _avatarFreezeGraphics:Object;
		private var _trickLog:Array;
		private var _receivedGameFinish:Boolean;

		public function SkateboardGameController(gameId:int)
		{
			super();

			_gameId = (gameId) ? gameId : DEFAULT_GAME_ASSET_ID;
		}

		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////


		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////

		override protected function setUp():void
		{
			super.setUp();

			trace('SkateboardGameController.setUp()');

			// Defaults.
			_avatarInspectEnabled = false;
			_shopEnabled = false;
			_printInviteEnabled = false;
			_useItemRollOverLabel = false;
			_scoreTricks = false;
			_allowKeyCombo = false;
			_trickMessaging = false;
			_allowKeyboardWalking = true;
			_allowLocalSkaterMove = true;
			_totalTricksByLocalUser = 0;
			_localPointMultiplier = 1;
			_trickTally = [];
			_avatarLabels = [];
			_preScoringPeriodLength = 5000;
			_postScoringPeriodLength = 5000;
			_postTrickDelay = 2000;
			_avatarColors = [];
			_defaultAvatarColor = 0xdd0000;
			_avatarNames = [];
			_itemsInRoom = [];
			_itemsInEffect = [];
			_pickUpMessageSentToServer = [];
			_localAvatarBaselineFilters = _localAvatar.display.filters;
			_avatarFreezeGraphics = {};
			_trickLog = [];

			// Build list of filters to apply to avatars that pick up specific items.
			_pickUpItemTypeAvatarFilters = [];
			_pickUpItemTypeAvatarFilters[1] = new GlowFilter(0x27a833, 1, 18, 18);
			_pickUpItemTypeAvatarFilters[2] = new GlowFilter(0xb11d51, 1, 18, 18);
			_pickUpItemTypeAvatarFilters[3] = new GlowFilter(0x639ad0, 1, 18, 18);

			// Get game params from global variable.
			// Remove reference when done.
			var gameParams:Object = ModelLocator.getInstance().incomingGameParams;
			_avatarColors = gameParams.avatarColors;
			ModelLocator.getInstance().incomingGameParams = null;

			// Create key combo map to map skate tricks.
			_keyComboMap = new KeyComboMap();
			_keyComboMap.addKeyCombo(['38', '39'], {name:'Kick Flip', value:200, animName:'kickflip', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'kick_flip.mp3'), minPlays: 0, trickId: 1});
			_keyComboMap.addKeyCombo(['38', '37'], {name:'Heel Flip', value:200, animName:'heelflip', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'heel_flip.mp3'), minPlays: 0, trickId: 2});
			_keyComboMap.addKeyCombo(['38', '40', '39'], {name:'360 Flip', value:300, animName:'360flip', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, '360_flip.mp3'), minPlays: 0, trickId: 3});
			_keyComboMap.addKeyCombo(['38', '40', '37'], {name:'Varial Flip', value:300, animName:'varialflip', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'varial.mp3'), minPlays: 1, trickId: 4});
			_keyComboMap.addKeyCombo(['38', '40', '40'], {name:'Hand Stand', value:300, animName:'handstand', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'hand_stand.mp3'), minPlays: 1, trickId: 5});
			_keyComboMap.addKeyCombo(['38', '38', '37'], {name:'Pop Shove It', value:300, animName:'popshoveit', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'pop_shove_it.mp3'), minPlays: 1, trickId: 6});
			_keyComboMap.addKeyCombo(['38', '40', '38', '37'], {name:'Impossible', value:400, animName:'impossible', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'impossible.mp3'), minPlays: 10, trickId: 7});
			_keyComboMap.addKeyCombo(['38', '38', '40', '39'], {name:'Fingerflip', value:400, animName:'fingerflip', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'finger_flip.mp3'), minPlays: 10, trickId: 8});
			_keyComboMap.addKeyCombo(['38', '40', '38', '40'], {name:'Pogo', value:400, animName:'pogo', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'pogo.mp3'), minPlays: 20, trickId: 9});
			_keyComboMap.addKeyCombo(['38', '38', '40', '38'], {name:'Casper', value:400, animName:'casper', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'casper.mp3'), minPlays: 20, trickId: 10});
			_keyComboMap.addKeyCombo(['38', '38', '38', '37'], {name:'360 Spin', value:400, animName:'360spin', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, '360_spin.mp3'), minPlays: 30, trickId: 11});
			_keyComboMap.addKeyCombo(['38', '38', '38', '39'], {name:'Primo Slide', value:400, animName:'primoslide', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'primo_slide.mp3'), minPlays: 30, trickId: 12});
			_keyComboMap.addKeyCombo(['38', '38', '39', '39'], {name:'Street Plant', value:400, animName:'streetplant', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'street_plant.mp3'), minPlays: 40, trickId: 13});
			_keyComboMap.addKeyCombo(['38', '38', '39', '40'], {name:'Helipop', value:400, animName:'helipop', soundUrl: AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'helipop.mp3'), minPlays: 40, trickId: 14});

			// Add key listeners.
			_keyboardInputController.addKeyDownHandler(37, onTrickKeyDown);
			_keyboardInputController.addKeyDownHandler(38, onTrickKeyDown);
			_keyboardInputController.addKeyDownHandler(39, onTrickKeyDown);
			_keyboardInputController.addKeyDownHandler(40, onTrickKeyDown);

			// Create ui view.
			_uiView = new SkateGameUI(_animMan);
			_uiView.timeProgressValue = 1;
			_uiView.addEventListener(SkateGameUI.CLOSE_TRICK_SHEET, propegateUiEvent);
			_uiView.addEventListener(SkateGameUI.OPEN_TRICK_SHEET, propegateUiEvent);
			_uiView.addEventListener(GamePlaceChangeEvent.PLACE_DOWN, onSkaterPlaceDown);
			_uiView.addEventListener(GamePlaceChangeEvent.PLACE_UP, onSkaterPlaceUp);
			_roomView.uiLayer.addChild(DisplayObject(_uiView));

			// Create remote sound bank.
			_soundBank = new RemoteSoundBank();

			// Create an array of cheer sound urls.
			_cheerSoundUrls = [];
			_cheerSoundUrls.push(AssetUtil.GetGameAssetUrl(GameAssetId.SKATEBOARD_GAME, 'cheer.mp3'));
			_cheerSoundUrls.push(AssetUtil.GetGameAssetUrl(GameAssetId.SKATEBOARD_GAME, 'cheer_02.mp3'));
			_cheerSoundUrls.push(AssetUtil.GetGameAssetUrl(GameAssetId.SKATEBOARD_GAME, 'cheer_03.mp3'));
			_cheerSoundUrls.push(AssetUtil.GetGameAssetUrl(GameAssetId.SKATEBOARD_GAME, 'cheer_04.mp3'));

			// Walk & Path complete listener on local avatar.
			userController.addEventListener(Character.WALK_START, onLocalAvatarWalkStart);
			_localAvatar.entity.addEventListener(TileMapEntity.PATH_FOLLOW_COMPLETE, onLocalAvatarPathComplete);

			// Use system cursor, because we dont allow click wlaking in the skate game.
			_roomView.setCursor(null);
			_roomView.hideCustomCursor = true;

			// If local user has a leashed pet, unleash and message the user.
			if (_localAvatar.isPetLeashed())
			{
				PetManager.unleashPet(_localAvatar.leashedPetInventoryId);
				SdgAlertChrome.show('Your pet is waiting for you in your turf.', 'Pet Unleashed');
			}

			// Disable specific game console buttons.
			GameConsoleDelegate.gameConsole.setButtonEnabled('buttonfriends', false);
			//GameConsoleDelegate.gameConsole.setButtonEnabled('buttonpets', false);
			GameConsoleDelegate.gameConsole.setButtonEnabled('buttonbadges', false);
			GameConsoleDelegate.gameConsole.setButtonEnabled('buttonshop', false);
			GameConsoleDelegate.gameConsole.setButtonEnabled('buttonpda', false);

			// Hide speed shoes button.
			RoomModule.SetSpeedShoesButtonVisible(false);
			// Hide ASN button.
			RoomModule.SetASNButtonVisible(false);

			// Determine how many times the local user has played this game and display it.
			// Load game play count for the skate game.
			GamePlayCounter.loadAllTimeGamePlayCount(DEFAULT_GAME_ASSET_ID, onGamePlayCountLoaded);
			function onGamePlayCountLoaded():void
			{
				_uiView.localUserGamePlayCount = GamePlayCounter.getPlayCountAllTime(DEFAULT_GAME_ASSET_ID);
			}

			// Don't allow avatar apparel to be changed.
			PDAController.SaveAvatarApparelEnabled = false;

			// Disable full screen.
			GameConsole.allowFullScreen = false;

			// Message user that game is loading.
			_uiView.showMessage('Loading', 0);

			// Load skater animation set.
			var animResourceMap:RemoteResourceMap = new RemoteResourceMap();
			animResourceMap.setResource("animationSet", SdgResourceLocator.getInstance().getAnimationSet(_SKATER_ANIM_SET_ID));
			animResourceMap.addEventListener(Event.COMPLETE, onSkaterAnimationSetComplete);
			animResourceMap.load();

			function onSkaterAnimationSetComplete(e:Event):void
			{
				// Remove listener.
				animResourceMap.removeEventListener(Event.COMPLETE, onSkaterAnimationSetComplete);

				// Set generic animation set.
				_skaterAnimSet = animResourceMap.getContent("animationSet") as AnimationSet;

				// Setup clothing spritesheets for all current avatars.
				var allAvatars:Array = _room.getAllAvatars();
				var i:int = 0;
				var len:int = allAvatars.length;
				for (i; i < len; i++)
				{
					setupSkateAvatar(AvatarController(_context.getItemController(allAvatars[i], false)));
				}

				// Message user that we are waiting for game to start.
				_uiView.showMessage('Waiting for players', 0);

				// The local user is now ready for the game start.
				// Send a message to the server.
				trace('Begin listening for: ' + SocketEvent.LAUNCH_MULTIPLAYER_GAME);
				SocketClient.addPluginActionHandler(SocketEvent.LAUNCH_MULTIPLAYER_GAME, onLaunchGame);
				SocketClient.getInstance().sendPluginMessage('room_enumeration', 'mpUserGameReady', {avatarId: _localAvatar.avatarId, gameId: _gameId, roomId: _room.id});
			}
		}

		override protected function cleanUp():void
		{
			trace('SkateboardGameController.cleanUp()');

			// Remove all listeners.
			userController.removeEventListener(Character.WALK_START, onLocalAvatarWalkStart);
			_localAvatar.entity.removeEventListener(TileMapEntity.PATH_FOLLOW_COMPLETE, onLocalAvatarPathComplete);
			_uiView.removeEventListener(SkateGameUI.CLOSE_TRICK_SHEET, propegateUiEvent);
			_uiView.removeEventListener(SkateGameUI.OPEN_TRICK_SHEET, propegateUiEvent);
			_uiView.removeEventListener(GamePlaceChangeEvent.PLACE_DOWN, onSkaterPlaceDown);
			_uiView.removeEventListener(GamePlaceChangeEvent.PLACE_UP, onSkaterPlaceUp);

			// Destroy ui view.
			_roomView.uiLayer.removeChild(DisplayObject(_uiView));
			_uiView.destroy();
			_uiView = null;

			// Clean up sounds.
			_soundBank.clear();
			_soundBank = null;
			stopSkateRollLoop();
			_cheerSoundUrls = null;

			// Set the path complete animation back to its default.
			userController.pathCompleteAnimation = Character.DEFAULT_PATH_COMPLETE_ANIM;

			// Reset flags and references.
			_trickTally = null;
			_isLocalSkaterRolling = false;

			// Remove references.
			_avatarLabels = null;
			_trickLog = null;

			// Show speed shoes button.
			RoomModule.SetSpeedShoesButtonVisible(true);
			// Show ASN button.
			RoomModule.SetASNButtonVisible(true);

			super.cleanUp();

			// Cleanup key combo map.
			_keyComboMap.removeAll();
			_keyComboMap = null;

			// Have local avatar stop walking, to prevent the walk animation from playing indefinitely when they leave the room.
			_localAvatar.entity.stop();

			// Have local avatar load original clothing.
			_localAvatar.display.load();

			// Reset filters on local avatar.
			_localAvatar.display.filters = _localAvatarBaselineFilters;

			// Re-allow user to change avatar apparel.
			PDAController.SaveAvatarApparelEnabled = true;

			// Re-allow full screen.
			GameConsole.allowFullScreen = true;
		}

		override protected function onItemAdded(e:RoomEnumEvent):void
		{
			super.onItemAdded(e);

			// Setup clothing spritesheets for all avatars.
			// Make sure that the skater animation set has been loaded already.
			if (_skaterAnimSet && e.item.itemClassId == SdgItemClassId.AVATAR)
			{
				var avatarController:AvatarController = _context.getItemController(e.item, false) as AvatarController;
				if (avatarController) setupSkateAvatar(avatarController);
			}
		}

		override protected function onItemRemoved(e:RoomEnumEvent):void
		{
			// Make sure the item is an avatar.
			if (e.item.itemClassId != SdgItemClassId.AVATAR) return;

			// Do avatar cleanup.
			cleanUpSkateAvatar(Avatar(e.item));

			super.onItemRemoved(e);
		}

		override protected function handleCurrentInputDirection():Point
		{
			// Make sure local user is not currently doing a trick.
			// Also make sure that movement is enabled.
			if (_isLocalSkaterMidTrick || !_allowLocalSkaterMove) return new Point();

			// Make sure the user is not entering text into a text field.
			// If the user is entering text into a text field, ignore keyboard input direction.
			if (StageProxy.getInstance().stage.focus as TextField)
			{
				_uiView.showMessage('If trying to move, click ground and try again', 5000);
				return new Point();
			}

			return super.handleCurrentInputDirection();
		}

		override protected function stylizeSelectedRoomItem(itemController:IRoomItemController, isSelected:Boolean):void
		{
			super.stylizeSelectedRoomItem(itemController, isSelected);

			// Make sure the item is an avatar.
			if (itemController.item.itemClassId != SdgItemClassId.AVATAR) return;

			// Hide/show the skater name label.
			var skaterNameLabel:DisplayObject = DisplayObject(_avatarLabels[itemController.item.avatarId]);
			if (skaterNameLabel) skaterNameLabel.visible = !isSelected;
		}

		protected function doSkateTrick(keyCombo:KeyCombo, averageAccuracyDeviaiton:Number):void
		{
			// Make sure we aren't already performing a trick.
			if (_isLocalSkaterMidTrick) return;

			trace('doSkateTrick()');

			// Make sure game controller has not been cleaned up.
			if (!_uiView) return;

			// Trick name.
			var trickName:String = keyCombo.params.name;

			// Determine the duration of the trick animation.
			var animationName:String = (keyCombo.params.animName) ? keyCombo.params.animName : 'walk';
			var animSequence:ISequence = _skaterAnimSet.getSequence(animationName + '0');
			if (!animSequence)
			{
				animationName = 'walk';
				animSequence = _skaterAnimSet.getSequence(animationName + '0');
			}

			// Get animation frame count.
			var animFrameCount:int = animSequence.duration;
			// If animation is going to loop, take into account.
			if (animSequence.playbackInfo.loopCount > 1) animFrameCount *= animSequence.playbackInfo.loopCount;
			// Use frame rate to determine the milisecond duration.
			var animDuration:int = Math.round((animFrameCount / animSequence.playbackInfo.interval) * 1000);

			// Check if we should be scoring tricks right now.
			if (_scoreTricks)
			{
				// Tally trick.
				// Keep track of total trick count.
				// Keep track of idividual trick count.
				_totalTricksByLocalUser++;
				var thisTrickTally:int = int(_trickTally[trickName]) + 1;
				_trickTally[trickName] = thisTrickTally;
				// Of all tricks, how often does the user do this trick.
				var thisTrickProbability:Number = thisTrickTally / _totalTricksByLocalUser;

				// Process score.
				var baseComboScore:int = keyCombo.params.value;
				var finalTrickScore:Number = calculateTrickScore(baseComboScore, averageAccuracyDeviaiton, thisTrickProbability);
				// Apply local point muliplier.
				finalTrickScore *= _localPointMultiplier;

				// Send score to server.
				// Send avatar id, game id, points, room id.
				// Pass ep (extra params)
				// 'key;value|key;value'
				var extraParams:String = 'trickName;' + trickName;
				// Hard code game id.
				SocketClient.getInstance().sendPluginMessage('room_enumeration', 'mpAddToScore', {avatarId: _localAvatar.avatarId, gameId: _gameId, points: finalTrickScore, roomId: _room.id, ep: extraParams});
			}

			// Message the user.
			// Use a trick adjective to express when tricks are somewhat accurate or very accurate.
			var trickAdjective:String = '';
			if (averageAccuracyDeviaiton < 0.5) trickAdjective = 'Solid ';
			if (averageAccuracyDeviaiton < 0.1) trickAdjective = 'Perfect ';
			// Show trick name effect.
			_uiView.showStylizedMessage(trickAdjective + trickName, getColorForComboLength(keyCombo.keyCodes.length));

			// Handle flags for performing a trick.
			// Play sounds for performing trick.
			_isLocalSkaterMidTrick = true;

			// Stop current sound playing for local skater.
			var trickDuration:int = (animDuration) ? animDuration : _DEFAULT_TRICK_DURATION;
			var trickTimer:Timer = new Timer(trickDuration)
			trickTimer.addEventListener(TimerEvent.TIMER, onTrickTimer);
			stopSkateRollLoop();
			if (_localSkaterSoundChannel) _localSkaterSoundChannel.stop();
			_localSkaterSoundChannel = Sound(new SkateSnap()).play(0, 0, new SoundTransform(0.2, getPanFromItemPos(_localAvatar)));

			// Play trick sound.
			// Stop current trick sound.
			_lastPlayedTrickSoundUrl = keyCombo.params.soundUrl;
			_soundBank.playSound(keyCombo.params.soundUrl, 0.3);

			// Set the path complete animation to null so the skater will not stop the trick animation if they hit the wall.
			// We will set this back to the default when the trick is complete.
			userController.pathCompleteAnimation = null;

			// Do trick animation.
			userController.addEventListener(Character.ANIMATION_START, onAnimationStart);
			userController.animate(animationName);

			// Use a delay timer, in case the animation action never comes back from the server.
			Delay.CallFunctionAfterDelay(2000, animateActionTimeOut);

			// Dispatch trick event.
			dispatchEvent(new SkateTrickEvent(SkateTrickEvent.TRICK, trickName, averageAccuracyDeviaiton, _isLocalSkaterRolling, keyCombo.keyCodes.length));

			function onAnimationStart(e:Event):void
			{
				// Remove listener.
				userController.removeEventListener(Character.ANIMATION_START, onAnimationStart);
				// Start trick timer.
				trickTimer.start();
			}

			function animateActionTimeOut():void
			{
				// Make sure the trick animation has started.
				// Start the trick timer regardless.
				if (trickTimer && !trickTimer.running)
				{
					// Remove animation start listener.
					userController.removeEventListener(Character.ANIMATION_START, onAnimationStart);
					// Start trick timer.
					trickTimer.start();
				}
			}

			function onTrickTimer(e:TimerEvent):void
			{
				// Kill timer.
				trickTimer.removeEventListener(TimerEvent.TIMER, onTrickTimer);
				trickTimer.reset();
				trickTimer = null;

				// Set flag.
				_isLocalSkaterMidTrick = false;

				// Make sure the room hasnt been destroyed.
				// We can assume that if sound bank is null.
				if (!_soundBank) return;

				// Check if skate roll loop should continue.
				if (_isLocalSkaterRolling) startSkateRollLoop();

				// Play crowd cheer sound.
				_soundBank.playSound(getRandomCheerSoundUrl(), 0.2);

				// Animate crowd in background.
				var bg:Object = _roomView.background;
				if (bg['cheer']) bg.cheer();

				// Set the path complete animation back to its default.
				userController.pathCompleteAnimation = Character.DEFAULT_PATH_COMPLETE_ANIM;

				// Handle current user input direction.
				handleCurrentInputDirection();
			}
		}

		override protected function updateMouseCursor():void
		{
			// Do nothing, because we don't allow click walking in the skate game and we dont want to show the custom cursor.
		}

		override protected function handleAvatarDoubleClick():void
		{
			// Do nothing.
		}

		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////

		private function setupSkateAvatar(avatarController:AvatarController):void
		{
			// Create skater animation resource.
			var avatar:Avatar = Avatar(avatarController.item);
			var imageSource:BitmapData = Bitmap(new SkaterBodySpriteSheet()).bitmapData; // Skater body layer.

			// Keep reference to avatar names in array.
			// This is so that we still have all the avatar names at the end of the game, even if some drop off.
			_avatarNames[avatar.avatarId] = avatar.name;

			// Modify body layer color to match users in-world skin color.
			var skinItemId:int = avatar.getSkinItemId();
			imageSource.colorTransform(imageSource.rect, AvatarSprite.GetColorTransformForSkin(skinItemId));

			// Create clothes layer.
			var clothesLayer:BitmapData = Bitmap(new SkaterClothesSpriteSheet()).bitmapData;
			// Create color layer.
			var colorFill:BitmapData = new BitmapData(imageSource.width, imageSource.height, false, getAvatarColor(avatar.avatarId));
			var colorLayer:BitmapData = new BitmapData(imageSource.width, imageSource.height, true, 0x000000);
			colorLayer.copyPixels(colorFill, colorLayer.rect, new Point(), clothesLayer);
			colorFill.dispose();
			// Draw clothes on top of color.
			colorLayer.draw(clothesLayer, null, null, BlendMode.HARDLIGHT);
			clothesLayer.dispose();

			// Draw colored clothes onto body.
			imageSource.draw(colorLayer, null, null); // Draw skater clothes on top of body.
			colorLayer.dispose();

			// If it is a female avatar, draw hair layer.
			if (avatar.gender == 2)
			{
				var hairLayer:BitmapData = Bitmap(new SkaterGirlHairSpriteSheet()).bitmapData;
				// Modify color of hair layer to match that of the avatar.
				hairLayer.colorTransform(hairLayer.rect, AvatarSprite.GetColorTransformForHair(avatar.getHairItemId()));
				imageSource.copyPixels(hairLayer, hairLayer.rect, new Point(), null, null, true);
				hairLayer.dispose();
			}

			// Create sprite sheet object from composited image.
			var compositeFilters:Array = AvatarSprite.DefaultAvatarCompositeFilters;
			var spriteSheet:SpriteSheet = new SpriteSheet(120, 120, imageSource);
			var animationResource:AnimationSetResource = new AnimationSetResource(_skaterAnimSet, [spriteSheet], avatar, compositeFilters);

			// Set skater resource on avatar.
			AvatarSprite(avatar.display).setAnimationResource(animationResource);

			// Set a higher walk speed to make the skaters move faster.
			avatarController.walkSpeedMultiplier = 1.5;

			// Add avatar label.
			addAvatarLabel(avatar);

			// Add avatar to ui.
			_uiView.addAvatar(avatar.avatarId, 0, getAvatarColor(avatar.avatarId));

			// Remove references to help with garbage collection.
			avatar = null;
			imageSource = null;
			spriteSheet = null;
			animationResource = null;
			avatarController = null;
			colorFill = null;
			colorLayer = null;
			clothesLayer = null;
		}

		private function cleanUpSkateAvatar(avatar:Avatar):void
		{
			// Remove avatar label.
			removeAvatarLabel(avatar);

			// Remove avatar from ui.
			_uiView.removeAvatar(avatar.avatarId);
		}

		private function addAvatarLabel(avatar:Avatar):void
		{
			// Create a name label and have it follow the avatar.
			var nameLabel:TextField = new TextField();
			nameLabel.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
			nameLabel.autoSize = TextFieldAutoSize.CENTER;
			nameLabel.selectable = false;
			nameLabel.mouseEnabled = false;
			nameLabel.embedFonts = true;
			nameLabel.text = avatar.name;
			nameLabel.filters = [new GlowFilter(0, 1, 2, 2, 10)];
			var displayRect:Rectangle = avatar.display.getImageRect();
			nameLabel.x = displayRect.x + displayRect.width / 2 - nameLabel.width / 2;
			nameLabel.y = displayRect.y + displayRect.height + 5;
			avatar.display.addChild(nameLabel);

			// Keep track of avatar labels in an array.
			_avatarLabels[avatar.id] = nameLabel;
		}

		private function removeAvatarLabel(avatar:Avatar):void
		{
			// Remove avatar name label.
			var avatarDisplay:IRoomItemDisplay = avatar.display;
			if (!avatarDisplay) return;
			if (!_avatarLabels[avatar.id]) return;
			avatarDisplay.removeChild(_avatarLabels[avatar.id]);
			_avatarLabels[avatar.id] = null;
		}

		private function endKeyCombo(goodTiming:Boolean, lastAccuracyDeviation:Number, averageAccuracyDeviaiton:Number, keyCombo:KeyCombo = null):void
		{
			// Make sure the room has not been destroyed.
			// We can assume that if uiView is null.
			if (!_uiView) return;

			_uiView.removeEventListener(KeyComboEvent.NEW_VALUE, onNewKeyValue);
			_uiView.removeEventListener(KeyComboEvent.COMPLETE, onKeyComboComplete);
			_uiView.removeEventListener(KeyComboEvent.OFF_TIME, onKeyComboOffTime);
			_uiView.stopCurrentKeyCombo(_postTrickDelay);
			_isThereCurrentCombo = false;
			_currentComboComplete = true;

			// Sound channel for basic sound.
			var sndChannel:SoundChannel;

			// Handle valid or invalid combos.
			if (keyCombo)
			{
				// Make sure the local user has played enough to do this trick/combo.
				if (keyCombo.params.minPlays > _uiView.localUserGamePlayCount)
				{
					// User has not played enough games to do this trick.
					// Play invalid combo sound.
					sndChannel = Sound(new SkateErrorSound()).play(0, 0, new SoundTransform(0.4));
					// Message user how many more times they need to play to do this trick.
					var playsNeeded:int = keyCombo.params.minPlays - _uiView.localUserGamePlayCount;
					var msg:String = (playsNeeded > 1) ? playsNeeded + ' more games to do this trick.' : playsNeeded + ' more game to do this trick.';
					_uiView.showMessage(msg, 4000);
					// Log trick.
					logTrick(_INVALID_COMBO_TRICK_ID, _isLocalSkaterRolling);
				}
				else
				{
					// Do skate trick.
					doSkateTrick(keyCombo, averageAccuracyDeviaiton);
					// Log trick.
					logTrick(keyCombo.params.trickId, _isLocalSkaterRolling);
				}
			}
			else if (goodTiming)
			{
				// Message the user.
				_uiView.showMessage('Invalid combo', _postTrickDelay);
				// Play invalid combo sound.
				sndChannel = Sound(new SkateErrorSound()).play(0, 0, new SoundTransform(0.4));
				// Log trick.
				logTrick(_INVALID_COMBO_TRICK_ID, _isLocalSkaterRolling);
			}
			else
			{
				// Make sure trick messaging is still enabled.
				if (_trickMessaging)
				{
					// Message the user. Too soon or late timing.
					_uiView.showMessage((lastAccuracyDeviation > 1) ? 'Late timing. Press as bar touches circle.' : 'Too soon. Press as bar touches circle.', _postTrickDelay + 1000);
					// Play bad timing sound.
					sndChannel = Sound(new SkateErrorSound()).play(0, 0, new SoundTransform(0.4));
				}

				// Log trick.
				logTrick(_MISTIMED_TRICK_ID, _isLocalSkaterRolling);
			}

			// Remove current key combo controller.
			var timer:Timer = new Timer(_postTrickDelay);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();

			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;

				_currentComboComplete = false;
			}
		}

		private function calculateTrickScore(baseScore:Number, accuracyDeviation:Number, trickProbability:Number):Number
		{
			if (!_USE_HIGH_RES_SCORING) return baseScore;

			var riskedAmount:Number = baseScore * _SCORE_PERCENT_RISKED_ON_ACCURACY;
			baseScore -= riskedAmount;
			baseScore += riskedAmount * (1 - accuracyDeviation) * 2;

			// Score is only a fraction if skater is stationary.
			if (!_isLocalSkaterRolling) baseScore /= 1.5;

			// If more than 3 tricks have been performed, take into account the frequency of the trick.
			// If the user consistently does the same trick, the score will be lower.
			if (_totalTricksByLocalUser > 3) baseScore -= baseScore * (trickProbability / 2);

			return Math.round(baseScore);
		}

		private function getPanFromItemPos(item:SdgItem):Number
		{
			// Return a pan value (-1 to 1) based on horizontal screen position.
			var x:Number = item.display.x + item.display.width / 2;
			var halfScreenWidth:Number = 925 / 2;
			return (x - halfScreenWidth) / halfScreenWidth;
		}

		private function startSkateRollLoop():void
		{
			if (!_localAvatar) return;
			if (_skateRollLoop) stopSkateRollLoop();
			var skateRollSound:Sound = new SkateRollLoop() as Sound;
			if (!skateRollSound) return;
			_skateRollLoop = skateRollSound.play(0, 0, new SoundTransform(_SKATE_ROLL_VOLUME, getPanFromItemPos(_localAvatar)));
			_skateRollLoop.addEventListener(Event.SOUND_COMPLETE, onSkateRollLoopComplete);
			_skateRollLoopUpdateTimer = new Timer(500);
			_skateRollLoopUpdateTimer.addEventListener(TimerEvent.TIMER, onSkateRollUpdateTimer);
			_skateRollLoopUpdateTimer.start();
		}

		private function stopSkateRollLoop():void
		{
			if (!_skateRollLoop) return;
			_skateRollLoop.removeEventListener(Event.SOUND_COMPLETE, onSkateRollLoopComplete);
			_skateRollLoop.stop();
			_skateRollLoop = null;
			if (!_skateRollLoopUpdateTimer) return;
			_skateRollLoopUpdateTimer.removeEventListener(TimerEvent.TIMER, onSkateRollUpdateTimer);
			_skateRollLoopUpdateTimer.reset();
			_skateRollLoopUpdateTimer = null;
		}

		private function getRandomCheerSoundUrl():String
		{
			// Pull a random cheer sound url from an array.
			var index:int = _lastPlayedCheerIndex;
			var len:int = _cheerSoundUrls.length;
			while (index == _lastPlayedCheerIndex)
			{
				index = Math.round(Math.random() * (len - 1));
			}

			_lastPlayedCheerIndex = index;
			return _cheerSoundUrls[index];
		}

		private function getRandomColor():uint
		{
			var colors:Array = [0x2a7c33, 0x1e4aff, 0xe5a955, 0xf13f44];
			return colors[Math.round(Math.random() * (colors.length - 1))];
		}

		private function createPopUp(display:DisplayObject, backingAlpha:Number = 0.8):DisplayObject
		{
			var backing:Sprite = new Sprite();
			backing.graphics.beginFill(0, backingAlpha);
			backing.graphics.drawRect(0, 0, 925, 665);
			backing.addChild(display);
			display.x = backing.width / 2 - display.width / 2;
			display.y = backing.height / 2 - display.height / 2;

			return backing;
		}

		private function getAvatarColor(avatarId:int):uint
		{
			return (_avatarColors[avatarId] != null) ? _avatarColors[avatarId] : _defaultAvatarColor;
		}

		private function stopCurrentTrickSound():void
		{
			if (_lastPlayedTrickSoundUrl) _soundBank.stopSound(_lastPlayedTrickSoundUrl);
			_lastPlayedTrickSoundUrl = null;
		}

		private function getColorForComboLength(length:int):uint
		{
			switch (length)
			{
				case 3:
					return 0xfecb00;
				case 4:
					return 0xf33200;
				default:
					return 0xcbcbcb;
			}
		}

		private function getPickUpItemInRoom(instanceId:int):SdgItem
		{
			var i:int = 0;
			var len:int = _itemsInRoom.length;
			for (i; i < len; i++)
			{
				var item:SdgItem = _itemsInRoom[i];
				if (item.instanceId == instanceId) return item;
			}

			return null;
		}

		private function getPickUpItemInEffect(instanceId:int):SdgItem
		{
			var i:int = 0;
			var len:int = _itemsInEffect.length;
			for (i; i < len; i++)
			{
				var item:SdgItem = _itemsInEffect[i];
				if (item.instanceId == instanceId) return item;
			}

			return null;
		}

		private function removePickUpItemFromRoomWithInstanceId(instanceId:int):void
		{
			if (!_room)
			{
				trace('removePickUpItemFromRoomWithInstanceId(); _room is null!');
				return;
			}

			var i:int = 0;
			var len:int = _itemsInRoom.length;
			var index:int;
			for (i; i < len; i++)
			{
				var item:SdgItem = _itemsInRoom[i];
				if (item.instanceId == instanceId)
				{
					index = i;
					i = len;
				}
			}

			if (index > -1)
			{
				_room.removeItem(_itemsInRoom[index]);
				_itemsInRoom.splice(index, 1);
			}
		}

		private function removePickUpItemFromRoom(item:SdgItem, animateOut:Boolean = false):void
		{
			var index:int = _itemsInRoom.indexOf(item);
			if (index > -1) _itemsInRoom.splice(index, 1);

			// Determine if we should animate out the item.
			if (animateOut)
			{
				// Delay removing the item from the room temporarily so that we can play an animation.
				// Play the animation.
				var itemDisplay:Object = item.display.content;
				if (itemDisplay && itemDisplay['pickup']) MovieClip(itemDisplay['pickup']).gotoAndPlay('pickup')
				// Use timer to delay the removal.
				Delay.CallFunctionAfterDelay(1000, onDelayComplete);
			}
			else
			{
				_room.removeItem(item);
			}

			function onDelayComplete():void
			{
				// Remove the item from the room.
				_room.removeItem(item);
			}
		}

		private function removeAllPickUpItemsFromRoom():void
		{
			var i:int = 0;
			var len:int = _itemsInRoom.length;
			for (i; i < len; i++)
			{
				_room.removeItem(_itemsInRoom[i]);
			}

			_itemsInRoom = [];
		}

		private function handleMultiplierItem(avatarId:int, multiplier:Number):void
		{
			// Apply filter to avatar.
			var avatar:Avatar = _room.getAvatarById(avatarId);
			if (!avatar) return;
			var filter:Object = (multiplier == 2) ? _pickUpItemTypeAvatarFilters[1] : _pickUpItemTypeAvatarFilters[2];
			avatar.display.filters = avatar.display.filters.concat(filter);

			// If it's the local avatar, apply the point multiplier.
			if (avatarId == _localAvatar.avatarId)
			{
				_localPointMultiplier *= multiplier;
				_uiView.scoreMultiplier = _localPointMultiplier;
			}
		}

		private function removeMultiplierItemEffect(avatarId:int, item:PrizeItem):void
		{
			// Remove multiplier filter.
			var avatar:Avatar = _room.getAvatarById(avatarId);
			if (!avatar) return;
			// Get filter based on item type.
			var filter:Object = (item.value == 2) ? _pickUpItemTypeAvatarFilters[2] : _pickUpItemTypeAvatarFilters[1];
			removeAvatarFilter(avatar, filter);

			// If it's the local avatar, reset the local point multiplier.
			if (avatarId == _localAvatar.avatarId)
			{
				_localPointMultiplier /= getMultiplierWithPickUpType(item.value);
				_uiView.scoreMultiplier = _localPointMultiplier;
			}
		}

		private function handleFreezeItem(avatarId:int):void
		{
			// Apply filter to all avatars but the one that picked up the item.
			var allAvatars:Array = _room.getAllAvatars();
			var i:int = 0;
			var len:int = allAvatars.length;
			for (i; i < len; i++)
			{
				var avatar:Avatar = allAvatars[i];
				if (avatar.avatarId != avatarId)
				{
					// Apply freeze filter.
					avatar.display.filters = avatar.display.filters.concat(_pickUpItemTypeAvatarFilters[3]);
					// Show freeze graphic over avatar.
					// First remove any current freeze.
					var currentFreeze:DisplayObject = _avatarFreezeGraphics[avatar.avatarId];
					if (currentFreeze) avatar.display.removeChild(currentFreeze);
					// Make new freeze.
					var frz:DisplayObject = new FreezeGraphic();
					var avRect:Rectangle = avatar.display.getImageRect();
					frz.x = avRect.x + avRect.width / 2;
					frz.y = avRect.y + avRect.height;
					// Keep reference to freeze graphic for later clean up.
					_avatarFreezeGraphics[avatar.avatarId] = frz;
					avatar.display.addChild(frz);
				}
			}

			// If not picked up by local avatar, prevent movement and tricks.
			if (avatarId != _localAvatar.avatarId) _allowLocalSkaterMove = _allowKeyCombo = false;
		}

		private function removeFreezeItem(avatarId:int):void
		{
			// Reset avatar filters.
			var allAvatars:Array = _room.getAllAvatars();
			var i:int = 0;
			var len:int = allAvatars.length;
			for (i; i < len; i++)
			{
				var avatar:Avatar = allAvatars[i];
				if (avatar.avatarId != avatarId)
				{
					// Remove freeze filter.
					removeAvatarFilter(avatar, _pickUpItemTypeAvatarFilters[3]);
					// Remove freeze graphic.
					var currentFreeze:DisplayObject = _avatarFreezeGraphics[avatar.avatarId];
					if (currentFreeze) avatar.display.removeChild(currentFreeze);
					_avatarFreezeGraphics[avatar.avatarId] = null;
				}
			}

			// If not picked up by local avatar, reallow movement and tricks.
			if (avatarId != _localAvatar.avatarId) _allowLocalSkaterMove = _allowKeyCombo = true;
		}

		private function removeInEffectItem(item:PrizeItem):void
		{
			// Remove item from list.
			if (!item) return;
			var index:int = _itemsInEffect.indexOf(item);
			if (index > -1) _itemsInEffect.splice(index, 1);

			var avatarId:int = item.avatarId;

			// Handle item complete based on item type.
			switch (item.value)
			{
				case 1:
					removeMultiplierItemEffect(avatarId, item);
					break;
				case 2:
					removeMultiplierItemEffect(avatarId, item);
					break;
				case 3:
					removeFreezeItem(avatarId);
					break;
				default:
					removeMultiplierItemEffect(avatarId, item);
			}
		}

		private function removeAllInEffectItems():void
		{
			var i:int = 0;
			var len:int = _itemsInEffect.length;
			for (i; i < len; i++)
			{
				removeInEffectItem(_itemsInEffect[i]);
			}
		}

		private function removeAvatarFilter(avatar:Avatar, filter:Object):void
		{
			// Remove filter.
			var currentFilters:Array = avatar.display.filters;
			var index:int = currentFilters.indexOf(filter);
			if (index) currentFilters.splice(index, 1);
			avatar.display.filters = currentFilters;
		}

		private function getMultiplierWithPickUpType(typeId:int):Number
		{
			return (typeId == 2) ? 3 : 2;
		}

		private function logTrick(trickId:int, isMoving:Boolean = false):void
		{
			_trickLog.push({trickId: trickId, isMoving: (isMoving) ? '1' : '0'});
		}

		////////////////////
		// EVENT HANDLERS
		////////////////////

		private function onTrickKeyDown(e:KeyboardEvent):void
		{
			// Check if we are starting a new key combo or adding to an existing one.
			if (!_allowKeyCombo || _currentComboComplete) return;
			if (_isThereCurrentCombo)
			{
				// Add to the existing key combo.
				_uiView.attemptToSetNextValue(e.keyCode.toString());
				return;
			}
			else if (e.keyCode == 38)
			{
				// The user pressed the up key.
				// Start a new key combo.
				_uiView.startNewKeyCombo(e.keyCode.toString(), 600, 4, 300, 120);
				_uiView.addEventListener(KeyComboEvent.NEW_VALUE, onNewKeyValue);
				_uiView.addEventListener(KeyComboEvent.COMPLETE, onKeyComboComplete);
				_uiView.addEventListener(KeyComboEvent.OFF_TIME, onKeyComboOffTime);
				_isThereCurrentCombo = true;
			}
		}

		private function onNewKeyValue(e:KeyComboEvent):void
		{
			// Try to get the key combo from the key combo map.
			var keyCombo:KeyCombo = _keyComboMap.getKeyCombo(e.keyValues);
			if (keyCombo)
			{
				endKeyCombo(true, e.lastAccuracyDeviation, e.averageAccuracyDeviation, keyCombo);
			}
		}

		private function onKeyComboComplete(e:KeyComboEvent):void
		{
			// Try to get the key combo from the key combo map.
			var keyCombo:KeyCombo = _keyComboMap.getKeyCombo(e.keyValues);
			if (keyCombo)
			{
				endKeyCombo(true, e.lastAccuracyDeviation, e.averageAccuracyDeviation, keyCombo);
			}
			else
			{
				endKeyCombo(true, e.lastAccuracyDeviation, e.averageAccuracyDeviation);
			}
		}

		private function onKeyComboOffTime(e:KeyComboEvent):void
		{
			endKeyCombo(false, e.lastAccuracyDeviation, e.averageAccuracyDeviation);
		}

		override protected function onMouseDownRoom(e:MouseEvent):void
		{
			// Make sure the user is not entering text into a text field.
			if (StageProxy.getInstance().stage.focus as TextField)
			{
				// If the user was entering text, remove keyboard focus from the text field.
				StageProxy.getInstance().stage.focus = null;
				return;
			}

			// If there is no mouse item, walk to tile.
			if (_mouseItemController) return;

			// Make sure the mouse is not over the UI layer.
			if (_mouseOverUiLayer) return;

			// Don't allow walking via the standard clicking method.
			// Message the user.
			_uiView.showMessage('Use keyboard to move (W, A, S, D)', 3000);

			// Play buzz sound.
			var sndChannel:SoundChannel = Sound(new SkateErrorSound()).play(0, 0, new SoundTransform(0.4));
		}

		private function onSkateRollLoopComplete(e:Event):void
		{
			// Restart the skate roll loop.
			_skateRollLoop.removeEventListener(Event.SOUND_COMPLETE, onSkateRollLoopComplete);
			if (!_isLocalSkaterRolling) return;
			_skateRollLoop = Sound(new SkateRollLoop()).play(0, 0, new SoundTransform(_SKATE_ROLL_VOLUME, getPanFromItemPos(_localAvatar)));
			_skateRollLoop.addEventListener(Event.SOUND_COMPLETE, onSkateRollLoopComplete);
		}

		private function onSkateRollUpdateTimer(e:TimerEvent):void
		{
			// Update panning of skate roll loop, to reflect position of local avatar on screen.
			if (_skateRollLoop) _skateRollLoop.soundTransform = new SoundTransform(0.05, getPanFromItemPos(_localAvatar));
		}

		private function onLocalAvatarPathComplete(e:Event):void
		{
			if (!_isLocalSkaterRolling) return;
			_isLocalSkaterRolling = false;

			// Local skater has stopped moving.
			// Stop the skate roll loop.
			stopSkateRollLoop();

			// Play skate stop sound.
			if (_localSkaterSoundChannel) _localSkaterSoundChannel.stop();
			_localSkaterSoundChannel = Sound(new SkateStop()).play(0, 0, new SoundTransform(0.03, getPanFromItemPos(_localAvatar)));
		}

		private function onLocalAvatarWalkStart(e:Event):void
		{
			if (_isLocalSkaterRolling) return;
			_isLocalSkaterRolling = true;

			// Local skater is beginning to move.
			// Start the skate roll loop.
			if (_isLocalSkaterRolling) startSkateRollLoop();
		}

		protected function onLaunchGame(e:SocketEvent):void
		{
			// Remove listener.
			SocketClient.removePluginActionHandler(SocketEvent.LAUNCH_MULTIPLAYER_GAME, onLaunchGame);

			trace('Received ' + SocketEvent.LAUNCH_MULTIPLAYER_GAME);

			// Make sure the game controller has not been destroyed.
			if (!_uiView) return;

			// Listen for game finish.
			SocketClient.addPluginActionHandler('mpGameFinish', onGameFinish);

			// Get game params.
			var paramsXml:XML = e.createParamsXml();
			_gameLength = paramsXml.gameLength;
			_gameLaunchTime = paramsXml.systemTime;

			// Determine if we need to count down into the scoring period.
			var scorePeriodStart:int = _gameLaunchTime + _preScoringPeriodLength;
			var timeUntilScorePeriod:int = scorePeriodStart - ModelLocator.getInstance().serverDate.time;
			var startScorePeriodTimer:Timer;
			var countdownTimer:Timer;
			if (timeUntilScorePeriod > 0)
			{
				trace(timeUntilScorePeriod + ' until scoring period starts.');
				startScorePeriodTimer = new Timer(timeUntilScorePeriod);
				startScorePeriodTimer.addEventListener(TimerEvent.TIMER, onStartScorePeriodTimer);
				startScorePeriodTimer.start();

				countdownTimer = new Timer(1000, Math.floor(timeUntilScorePeriod / 1000));
				countdownTimer.addEventListener(TimerEvent.TIMER, onCountdownTimer);
				countdownTimer.start();
			}
			else
			{
				// Start score period.
				trace('Scoring period has already started. Game ends at ' + Number(_gameLaunchTime + _gameLength).toString());
				startScorePeriod();
			}

			// Show an effect over the local avatar's head to show the user which skater is theirs.
			userController.showOverheadAsset(new ThisIsYouGraphic(), 5000, false, 20);

			function startScorePeriod():void
			{
				// Make sure game controller has not been cleaned up.
				if (!_uiView) return;
				// Message to users that game has started.
				_uiView.showMessage('Start', 5000);
				// Allow scoring of tricks.
				_scoreTricks = true;
				_trickMessaging = true;
				_allowKeyCombo = true;
				// Listen for when the user avatar moves.
				// This is so we can detect collision with item pickups.
				_localAvatar.entity.data.addEventListener(SimEvent.MOVED, onUserAvatarMove);
				// Listen for server messages.
				SocketClient.addPluginActionHandler('mpAddToScore', onAddToScore);
				SocketClient.addPluginActionHandler('mpDropItem', onDropItem);
				SocketClient.addPluginActionHandler('mpRemoveItem', onRemoveItem);
				SocketClient.addPluginActionHandler('mpPickUpItem', onPickUpItem);
				SocketClient.addPluginActionHandler('mpItemComplete', onItemComplete);

				// Use a timer that triggers periodicaly to determine when we will need to start counting down to the end of the game.
				_gameTimeCheckTimer = new Timer(2000);
				_gameTimeCheckTimer.addEventListener(TimerEvent.TIMER, onGameTimeCheckTimer);
				_gameTimeCheckTimer.start();
			}

			function onStartScorePeriodTimer(e:TimerEvent):void
			{
				// Kill timer.
				startScorePeriodTimer.removeEventListener(TimerEvent.TIMER, onStartScorePeriodTimer);
				startScorePeriodTimer.reset();
				startScorePeriodTimer = null;
				// Start score period.
				startScorePeriod();
			}

			function onCountdownTimer(e:TimerEvent):void
			{
				// Determine time until score period starts.
				timeUntilScorePeriod = scorePeriodStart - ModelLocator.getInstance().serverDate.time;

				// Check if timer is complete.
				if (countdownTimer.currentCount >= countdownTimer.repeatCount || timeUntilScorePeriod < 1000 || !_uiView)
				{
					countdownTimer.removeEventListener(TimerEvent.TIMER, onCountdownTimer);
					countdownTimer.reset();
					countdownTimer = null;
				}

				// Show countdown message.
				timeUntilScorePeriod = scorePeriodStart - ModelLocator.getInstance().serverDate.time;
				if (_uiView) _uiView.showMessage(String(Math.ceil(timeUntilScorePeriod / 1000)), 0);
			}
		}

		protected function onAddToScore(e:SocketEvent):void
		{
			// A user has scored.
			var paramsXml:XML = e.createParamsXml();
			var avatarId:int = paramsXml.avatarId;
			var points:int = paramsXml.points;
			var pointsTotal:int = paramsXml.pointsTotal;

			if (!_uiView) return;

			// Update score on UI.
			_uiView.setAvatarScore(avatarId, pointsTotal);

			// Set local avatar score on UI.
			// Also log server message latency.
			if (avatarId == _localAvatar.avatarId) _uiView.points = pointsTotal;

			// Parse extra parameters.
			var encodedParams:Array = String(paramsXml.ep).split('|');
			var extraParams:Object = {};
			for each (var encodedParam:String in encodedParams)
			{
				var vals:Array = encodedParam.split(';', 2);
				extraParams[vals[0]] = vals[1];
			}

			// Get trick name from extra parameters.
			// Try to get a key combo using the trick name.
			var trickName:String = (extraParams['trickName']) ? extraParams.trickName : null;
			var keyCombo:KeyCombo = _keyComboMap.getByParam('name', trickName);

			// Show score over avatars head.
			var avatar:Avatar = _room.getAvatarById(avatarId);
			var avatarController:AvatarController = (avatar) ? AvatarController(_context.getItemController(avatar, false)) : null;
			if (avatarController)
			{
				var scoreEffect:SkateScoreOverhead = new SkateScoreOverhead();
				scoreEffect.value = points;
				scoreEffect.color = getColorForComboLength((keyCombo) ? keyCombo.keyCodes.length : 0);
				avatarController.showOverheadAsset(scoreEffect, 3000, false, 5);
			}
		}

		private function onGameFinish(e:SocketEvent):void
		{
			// Make sure we have not already received a game finish.
			if (_receivedGameFinish) return;
			_receivedGameFinish = true;

			// Remove socket server listeners.
			SocketClient.removePluginActionHandler('mpGameFinish', onGameFinish);
			SocketClient.removePluginActionHandler('mpAddToScore', onAddToScore);
			SocketClient.removePluginActionHandler('mpDropItem', onDropItem);
			SocketClient.removePluginActionHandler('mpRemoveItem', onRemoveItem);
			SocketClient.removePluginActionHandler('mpPickUpItem', onPickUpItem);
			SocketClient.removePluginActionHandler('mpItemComplete', onItemComplete);
			// Remove avatar move listener.
			// We no longer need to detect collision.
			_localAvatar.entity.data.removeEventListener(SimEvent.MOVED, onUserAvatarMove);

			// Get scores.
			var paramsXml:XML = e.createParamsXml();
			var encodedScores:String = paramsXml.avatarScores;
			var scoreSets:Array = encodedScores.split('|', 20);
			trace('Encoded results:\n' +scoreSets.toString());
			// Create objects that contain score values.
			var avatarScoreObjects:Array = [];
			for each (var avScoreString:String in scoreSets)
			{
				var vals:Array = avScoreString.split(';', 2);
				var avatarId:int = vals[0];
				var name:String = _avatarNames[avatarId];
				var score:int = vals[1];
				var color:uint = getAvatarColor(avatarId);
				avatarScoreObjects.push({avatarId: avatarId, name: name, score: score, color: color});
			}

			// Sort avatar score objects by score.
			avatarScoreObjects.sort(avatarScoreSort);

			// Arrange the score data in a way that the finish screen can understand.
			var nameArray:Array = [];
			var scoreArray:Array = [];
			var colorArray:Array = [];
			for each (var avatarScoreObject:Object in avatarScoreObjects)
			{
				nameArray.push(avatarScoreObject.name);
				scoreArray.push(avatarScoreObject.score);
				colorArray.push(avatarScoreObject.color);
			}

			// Force user to exit room.
			// Hard code to skate park.
			RoomManager.getInstance().enterRoom('public_202', false);

			// Increment game play.
			GamePlayCounter.incrementGamePlay(_gameId);

			// Load game finish screen and show it.
			var finishScreenLoader:QuickLoader = new QuickLoader(AssetUtil.GetGameAssetUrl(99, 'multi_user_game_finish.swf'), onFinishScreenComplete);

			function onFinishScreenComplete():void
			{
				// Show game finish screen.
				var finishScreen:DisplayObject = finishScreenLoader.content;
				var finishScreenPopUp:DisplayObject = createPopUp(finishScreen);
				var finishScreenObject:Object = finishScreen;
				if (finishScreenObject.setValues) finishScreenObject.setValues(nameArray, scoreArray, colorArray, _localAvatar.name);
				// Check for local avatar rewards rewards.
				var tokenReward:Reward = e.rewards.getRewardByTypeAndAvatarId(Reward.CURRENCY, _localAvatar.avatarId);
				var xpReward:Reward = e.rewards.getRewardByTypeAndAvatarId(Reward.EXPERIENCE, _localAvatar.avatarId);
				// Set reward values on finish screen.
				if (finishScreenObject.tokens) finishScreenObject.tokens = (tokenReward) ? tokenReward.rewardValue : 0;
				if (finishScreenObject.points) finishScreenObject.points = (xpReward) ? xpReward.rewardValue : 0;
				finishScreen.addEventListener(Event.CLOSE, onFinishScreenClose);
				_roomView.addPopUp(finishScreenPopUp);
				finishScreenLoader = null;
				finishScreenObject = null;

				function onFinishScreenClose(e:Event):void
				{
					// Remove finish screen.
					finishScreen.removeEventListener(Event.CLOSE, onFinishScreenClose);
					_roomView.removePopUp(finishScreenPopUp);
					finishScreen = null;
					finishScreenPopUp = null;
				}
			}

			function avatarScoreSort(a:Object, b:Object):int
			{
				if (a.score < b.score)
				{
					return 1;
				}
				else if (a.score > b.score)
				{
					return -1;
				}
				else
				{
					return 0;
				}
			}
		}

		private function propegateUiEvent(e:Event):void
		{
			dispatchEvent(new Event(e.type));
		}

		private function onGameTimeCheckTimer(e:TimerEvent):void
		{
			// Determine if we need to start a countdown to the end of the game.
			var countdownLength:int = 10000; // 10 seconds
			var countdownStartTime:int = _gameLaunchTime + _gameLength - _postScoringPeriodLength - countdownLength;
			var timeUntilCountdown:int = countdownStartTime - ModelLocator.getInstance().serverDate.time;
			// If the countdown will start in less than 5 seconds, start a timer to trigger the countdown.
			var countdownStartTimer:Timer;
			var countdownTimer:Timer;
			if (!_timerToCountdownStarted && timeUntilCountdown < 5000)
			{
				// Start timer to trigger countdown period.
				countdownStartTimer = new Timer(timeUntilCountdown);
				countdownStartTimer.addEventListener(TimerEvent.TIMER, onCountdownStartTimer);
				countdownStartTimer.start();

				_timerToCountdownStarted = true;
			}

			// Update the time progress on the ui.
			if (_uiView) _uiView.timeProgressValue = ((timeUntilCountdown + countdownLength) / (_gameLength - _preScoringPeriodLength - _postScoringPeriodLength));

			function onCountdownStartTimer(e:TimerEvent):void
			{
				// Kill timer.
				countdownStartTimer.removeEventListener(TimerEvent.TIMER, onCountdownStartTimer);
				countdownStartTimer.reset();
				countdownStartTimer = null;

				if (!_uiView) return;

				// There is "countdownLength" amount of time until the scoring period is over.
				// Message this.
				_uiView.showMessage(Math.ceil(countdownLength / 1000) + ' Seconds', 3000);
				// Play sound.
				_soundBank.playSound(AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, '10_seconds.mp3'), 0.5);

				// Start countdown.
				countdownTimer = new Timer(1000);
				countdownTimer.addEventListener(TimerEvent.TIMER, onCountdownTimer);
				countdownTimer.start();
			}

			function onCountdownTimer(e:TimerEvent):void
			{
				// Determine time until game end.
				var timeUntilGameEnd:int = _gameLaunchTime + _gameLength - _postScoringPeriodLength - ModelLocator.getInstance().serverDate.time;

				// Check if we should kill the itmer.
				if (timeUntilGameEnd < 1000 || !_uiView)
				{
					// Kill timer.
					countdownTimer.removeEventListener(TimerEvent.TIMER, onCountdownTimer);
					countdownTimer.reset();
					countdownTimer = null;

					// Finish scoring period.
					finishScoringPeriod();
				}

				// Show countdown message.
				//if (_uiView) _uiView.showMessage(String(Math.ceil(timeUntilGameEnd / 1000)), 0);
			}

			function finishScoringPeriod():void
			{
				// Kill "_gameTimeCheckTimer" timer.
				_gameTimeCheckTimer.removeEventListener(TimerEvent.TIMER, onGameTimeCheckTimer);
				_gameTimeCheckTimer.reset();
				_gameTimeCheckTimer = null;

				if (!_uiView) return;

				// Encode trick log for server.
				var encodedTrickLog:String = '';
				for each (var loggedTrick:Object in _trickLog)
				{
					//{trickId: trickId, isMoving: (isMoving) ? '1' : '0'}
					// Determine trick id.
					var trickId:int = loggedTrick.trickId;;
					var isMoving:int = loggedTrick.isMoving;
					var encodedTrick:String = trickId + ';' + isMoving + ';' + _uiView.localUserGamePlayCount + '~';
					encodedTrickLog += encodedTrick;
				}
				SocketClient.getInstance().sendPluginMessage('room_enumeration', 'mpGameFinishClient', {avatarId: _localAvatar.avatarId, roomId: _room.id, gameId: _gameId, trickLog: encodedTrickLog});

				// Remove all pickup items from room.
				removeAllPickUpItemsFromRoom();
				// Remove all in effect items.
				removeAllInEffectItems();
				// Message finish.
				_uiView.showMessage('Finish', 0);
				// Play sound.
				_soundBank.playSound(AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'nice_skating.mp3'), 0.5);

				// Dont allow further scoring.
				_allowKeyCombo = false;
				_trickMessaging = false;
				_scoreTricks = false;

				// Animate crowd in background.
				var bg:Object = _roomView.background;
				if (bg['cheer']) bg.cheer(_postScoringPeriodLength);

				// Update the time progress on the ui.
				_uiView.timeProgressValue = 0;

				// If there was more than 1 player and the local user won, show the win effect.
				if (_uiView.numAvatars > 1 && _uiView.getLeadingScoreAvatarId() == _localAvatar.avatarId) _uiView.showWinEffect();
			}
		}

		private function onSkaterPlaceDown(e:GamePlaceChangeEvent):void
		{
			// A skater has moved down in place.
			// If it's the local avatar play some sound.
			if (e.id != _localAvatar.avatarId) return;
			if (e.previousPlace == 0 && e.currentPlace == 1)
			{
				// Local skater lost the lead.
				stopCurrentTrickSound();
				_soundBank.playSound(AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'you_lost_the_lead.mp3'), 0.3);
			}
		}

		private function onSkaterPlaceUp(e:GamePlaceChangeEvent):void
		{
			// A skater has moved up in place.
			// If it's the local avatar play some sound.
			if (e.id != _localAvatar.avatarId) return;
			if (e.previousPlace == 1 && e.currentPlace == 0)
			{
				// Local skater gained the lead.
				stopCurrentTrickSound();
				_soundBank.playSound(AssetUtil.GetGameAssetUrl(DEFAULT_GAME_ASSET_ID, 'youre_in_the_lead.mp3'), 0.3);
			}
		}

		private function onTrickSoundComplete(e:Event):void
		{
			stopCurrentTrickSound();
		}

		private function onDropItem(e:SocketEvent):void
		{
			// Make sure the scoring period hasnt ended.
			if (!_scoreTricks) return;

			// Make sure we have a reference to room.
			if (!_room)
			{
				trace('onDropItem(); ROOM IS NULL');
				return;
			}

			// Get event params.
			var paramsXml:XML = e.createParamsXml();
			if (!paramsXml) return;
			var instanceId:int = paramsXml.itemId;
			var typeId:int = paramsXml.itemTypeId;
			var x:int = paramsXml.x;
			var y:int = paramsXml.y;

			// Determine itemId to use, based on typeId.
			// This links to a row in the Item table and ultimately an asset in "sdgdata", determining the appearance of the pickup.
			var itemId:int;
			switch (typeId)
			{
				case 1:
					itemId = 1122;
					break;
				case 2:
					itemId = 1123;
					break;
				case 3:
					itemId = 1124;
					break;
				default:
					itemId = 1122;
			}

			var item:PrizeItem = new PrizeItem(instanceId);
			item.itemId = itemId;
			item.numLayers = 1;
			item.layerType = RoomLayerType.FLOOR;
			item.assetType = SdgItemAssetType.SWF;
			item.spriteTemplateId = 19;
			item.x = x;
			item.y = y;
			item.entity.solidity = 0;
			item.value = typeId;

			// Keep in array.
			_itemsInRoom.push(item);

			// Add to room.
			_room.addItem(item);
		}

		private function onRemoveItem(e:SocketEvent):void
		{
			// Get event params.
			var paramsXml:XML = e.createParamsXml();
			var instanceId:int = paramsXml.itemId;

			// Remove item from room.
			removePickUpItemFromRoomWithInstanceId(instanceId);
		}

		private function onPickUpItem(e:SocketEvent):void
		{
			// Get event params.
			var paramsXml:XML = e.createParamsXml();
			var instanceId:int = paramsXml.itemId;
			var typeId:int = paramsXml.typeId;
			var avatarId:int = paramsXml.avatarId;
			var complettionTime:int = paramsXml.completionTime;

			// Keep track of items that are in effect.
			var itemInRoom:SdgItem = getPickUpItemInRoom(instanceId);
			if (!itemInRoom) return;
			// Set avatar.
			itemInRoom.avatarId = avatarId;
			_itemsInEffect.push(itemInRoom);

			// Remove the item from the room.
			// Animate out.
			removePickUpItemFromRoom(itemInRoom, true);

			// Set flag.
			_pickUpMessageSentToServer[itemInRoom.instanceId] = false;

			// If picked up by local avatar, play success sound.
			if (avatarId == _localAvatar.avatarId) _soundBank.playSound(AssetUtil.GetGameAssetUrl(GameAssetId.SKATEBOARD_GAME, 'success.mp3'), 0.3);

			// Apple the effects of the item to the avatar that picked it up.
			switch (typeId)
			{
				case 1:
				case 2:
					handleMultiplierItem(avatarId, getMultiplierWithPickUpType(typeId));
					break;
				case 3:
					handleFreezeItem(avatarId);
					break;
				default:
					handleMultiplierItem(avatarId, getMultiplierWithPickUpType(typeId));
			}
		}

		private function onItemComplete(e:SocketEvent):void
		{
			// Get event params.
			var paramsXml:XML = e.createParamsXml();
			var instanceId:int = paramsXml.itemId;
			// Get item.
			var item:PrizeItem = getPickUpItemInEffect(instanceId) as PrizeItem;
			if (!item) return;

			removeInEffectItem(item);
		}

		private function onUserAvatarMove(e:SimEvent):void
		{
			// Check if the user avatar collides with any pickups.
			// Get tile occupants for the tile position of the avatar.

			// Define collision threshold.
			// How close the avatar must be to an item o collide with it.
			// Give vertical threshold more slack because of the appearance that you are close to the item verticaly when you are actually not.
			// This is simply to prevent frustration.
			var collisionThresholdX:Number = 1;
			var collisionThresholdY:Number = 2;

			// Make sure there is still a room reference.
			if (!_room) return;

			var i:int = 0;
			var len:int = _itemsInRoom.length;
			var collidedItem:SdgItem;
			var userAvatarEntity:RoomEntity = _localAvatar.entity;
			for (i; i < len; i++)
			{
				// Get reference to item.
				var item:SdgItem = _itemsInRoom[i];
				if (item == null) return;

				// Get the x distance from this item to the user avatar.
				var xDis:Number = Math.abs(item.entity.x - userAvatarEntity.x);
				// Get the y distance from this item to the user avatar.
				var yDis:Number = Math.abs(item.entity.y - userAvatarEntity.y);

				// If the x distance and y distance are both less than 1,
				// We consider these 2 items to be colliding.
				if (xDis < collisionThresholdX && yDis < collisionThresholdY)
				{
					// Item collision.
					collidedItem = item;

					// Stop looping.
					i = len;
				}
			}

			// If there is a collided item.
			// Let the server know.
			if (collidedItem != null)
			{
				// Make sure the item has a display.
				if (!collidedItem.display) return;
				// Keep track of items that we have sent messages for.
				// This is to prevent redundant pick up messages.
				if (_pickUpMessageSentToServer[collidedItem.instanceId]) return;
				_pickUpMessageSentToServer[collidedItem.instanceId] = true;
				// Dispatch a message to the server.
				SocketClient.getInstance().sendPluginMessage('room_enumeration', 'mpPickUpItem', {avatarId: _localAvatar.avatarId, itemId: collidedItem.instanceId, roomId: _room.id});
			}
		}

	}
}

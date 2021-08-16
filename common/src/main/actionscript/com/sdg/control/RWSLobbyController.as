package com.sdg.control
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.sdg.events.AASEventManager;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.model.ActionAllStarsEventType;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.RoomInfo;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.net.socket.methods.SocketRoomMethods;
	import com.sdg.pickem.PickemEvent;
	import com.sdg.trivia.TriviaEvent;
	import com.sdg.trivia.TriviaEventCollection;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.IRoomView;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	public class RWSLobbyController extends CairngormEventController implements IDynamicController
	{
		private var _roomContainer:IRoomView;
		private var _background:Object;
		private var _triviaDoor:MovieClip;
		private var _triviaRoomSelectHud:MovieClip;
		private var _pickemDoor:MovieClip;
		private var _pickemRoomSelectHud:MovieClip;
		protected var _broadcastCenterRoomIds:Array = ['public_122', 'public_123', 'public_124', 'public_125'];
		protected var _pickemRoomIds:Array = ['public_131', 'public_132', 'public_133', 'public_134'];
		private var _tmr:Timer;
		private var _timeStepMax:int;
		private var _timeStep:int;
		private var _triviaPopUpIsShown:Boolean;
		private var _pickemPopUpIsShown:Boolean;
		private var _animationManager:AnimationManager;
		private var _triviaEvents:TriviaEventCollection;
		private var _pickemEvents:TriviaEventCollection;
		private var _upsellDialog:Sprite;
		private var _upsellIsShown:Boolean;
		
		private var _socketMethods:SocketRoomMethods;
		
		public function RWSLobbyController(roomContainer:IRoomView, data:Object)
		{
			super();
			
			// Get server time.
			SocketClient.getInstance().sendPluginMessage('avatar_handler', 'serverTime', { });
			
			// setup default values
			_roomContainer = roomContainer;
			_background = data.background;
			_triviaDoor = MovieClip(data.triviaDoor);
			_triviaRoomSelectHud = MovieClip(data.triviaRoomSelectHud);
			_pickemDoor = MovieClip(data.pickemDoor);
			_pickemRoomSelectHud = MovieClip(data.pickemRoomSelectHud);
			_socketMethods = new SocketRoomMethods();
			_tmr = new Timer(250);
			_timeStepMax = Math.floor(1000 / _tmr.delay);
			_timeStep = 0;
			_tmr.addEventListener(TimerEvent.TIMER, _timerInterval);
			_triviaPopUpIsShown = false;
			_pickemPopUpIsShown = false;
			_animationManager = new AnimationManager();
			_upsellIsShown = false;
			
			// Hide the trivia room select hud.
			_hideTriviaRoomSelectHud();
			
			// Hide the pickem room select hud.
			_hidePickemRoomSelectHud();
			
			// Listen for mouse events on the trivia door.
			_triviaDoor.addEventListener(MouseEvent.CLICK, _onTriviaDoorClick);
			
			// Listen for mouse events on the pickem door.
			_pickemDoor.addEventListener(MouseEvent.CLICK, _onPickemDoorClick);
			
			// Listen for events on the trivia room select hud.
			_triviaRoomSelectHud.addEventListener('close', _onTriviaHudClose);
			_triviaRoomSelectHud.addEventListener('enter room 1', _onEnterRoom1);
			_triviaRoomSelectHud.addEventListener('enter room 2', _onEnterRoom2);
			_triviaRoomSelectHud.addEventListener('enter room 3', _onEnterRoom3);
			_triviaRoomSelectHud.addEventListener('enter room 4', _onEnterRoom4);
			
			// Listen for events on the pickem room select hud.
			_pickemRoomSelectHud.addEventListener('close', _onPickemHudClose);
			_pickemRoomSelectHud.addEventListener('enter room 1', _onEnterRoom1);
			_pickemRoomSelectHud.addEventListener('enter room 2', _onEnterRoom2);
			_pickemRoomSelectHud.addEventListener('enter room 3', _onEnterRoom3);
			_pickemRoomSelectHud.addEventListener('enter room 4', _onEnterRoom4);
			
			// Query server for events.
			//RoomManager.getInstance().socketMethods.getRwsEvents();
			
			_tmr.start();
		}
		
		public function init():void
		{
			
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			_triviaDoor.removeEventListener(MouseEvent.CLICK, _onTriviaDoorClick);
			_triviaRoomSelectHud.removeEventListener('close', _onTriviaHudClose);
			_triviaRoomSelectHud.removeEventListener('enter room 1', _onEnterRoom1);
			_triviaRoomSelectHud.removeEventListener('enter room 2', _onEnterRoom2);
			_triviaRoomSelectHud.removeEventListener('enter room 3', _onEnterRoom3);
			_triviaRoomSelectHud.removeEventListener('enter room 4', _onEnterRoom4);
			_tmr.removeEventListener(TimerEvent.TIMER, _timerInterval);
			
			if (_upsellDialog != null)
			{
				// Remove upsell listeners.
				_upsellDialog.removeEventListener('Close', onUpsellClose);
				_upsellDialog.removeEventListener('NoThanks', onUpsellNoThanks);
				_upsellDialog.removeEventListener('GetMonthFree', onUpsellGetMonthFree);
				// Hide the upsell dialog.
				hideUpSell();
			}
			
			// Make sure the trivia room select hud is hidden.
			if (_triviaPopUpIsShown == true) _hideTriviaRoomSelectHud();
			
			// Make sure the pickem room select hud is hidden.
			if (_pickemPopUpIsShown == true) _hidePickemRoomSelectHud();
			
			_tmr.reset();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function _hideTriviaRoomSelectHud():void
		{
			_triviaRoomSelectHud.visible = false;
			_roomContainer.removePopUp(_triviaRoomSelectHud);
			_triviaPopUpIsShown = false;
		}
		private function _showTriviaRoomSelectHud():void
		{
			// Get number of avatars for every Broadcast Center room.
			// Then display the results in a UI and let the user choose a room to enter.
			var i:int = 0;
			var len:int = _broadcastCenterRoomIds.length;
			var roomInfoArray:Array = []; // [roomInfo, roomInfo, roomInfo]
			var roomInfo:RoomInfo;
			var roomId:String = _broadcastCenterRoomIds[i];
			_socketMethods.addEventListener(SocketRoomEvent.NUM_AVATARS, onNumAvatar);
			_socketMethods.getAvatarCountInRoom(roomId);
			
			function onNumAvatar(event:SocketRoomEvent):void
			{
				var _avatarXML:XML = XML(event.params.numAvatars);
				roomInfo = new RoomInfo(roomId, 'Broadcast Center ' + (i + 1), int(_avatarXML.numAvatars.*[0]), int(_avatarXML.maxAvatars.*[0]));
				roomInfoArray.push(roomInfo);
				i++;
				if (i < len)
				{
					// If we have more Broadcast Center rooms to check.
					roomId = _broadcastCenterRoomIds[i];
					_socketMethods.getAvatarCountInRoom(roomId);
				}
				else
				{
					// If we don't have any more Broadcast Center rooms to check.
					// Remove avatar count listener.
					_socketMethods.removeEventListener(SocketRoomEvent.NUM_AVATARS, onNumAvatar);
					
					// Create Trivia Room List UI.
					_triviaRoomSelectHud.roomCapacity1 = RoomInfo(roomInfoArray[0]).numAvatars;
					_triviaRoomSelectHud.roomCapacity2 = RoomInfo(roomInfoArray[1]).numAvatars;
					_triviaRoomSelectHud.roomCapacity3 = RoomInfo(roomInfoArray[2]).numAvatars;
					_triviaRoomSelectHud.roomCapacity4 = RoomInfo(roomInfoArray[3]).numAvatars;
					_roomContainer.addPopUp(_triviaRoomSelectHud);
					// Fade in the pop up
					_triviaRoomSelectHud.alpha = 0;
					_animationManager.alpha(_triviaRoomSelectHud, 1, 400, Transitions.CUBIC_OUT, RenderMethod.TIMER);
					_triviaRoomSelectHud.visible = true;
					_triviaPopUpIsShown = true;
				}
			}
		}
		
		private function _hidePickemRoomSelectHud():void
		{
			_pickemRoomSelectHud.visible = false;
			_roomContainer.removePopUp(_pickemRoomSelectHud);
			_pickemPopUpIsShown = false;
		}
		private function _showPickemRoomSelectHud():void
		{
			_roomContainer.addPopUp(_pickemRoomSelectHud);
			// Fade in the pop up.
			_pickemRoomSelectHud.alpha = 0;
			_animationManager.alpha(_pickemRoomSelectHud, 1, 400, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_pickemRoomSelectHud.visible = true;
			_pickemPopUpIsShown = true;
		}
		
		private function showUpSell():void
		{
			if (_upsellIsShown == true) return;
			
			if (_upsellDialog == null)
			{
				// Load the upsell dialogue.
				var url:String = 'assets/swfs/premium_feature_popup_sportsPsychic.swf';
				var request:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				trace('RWSLobbyController: Loading premium upsell pop up.');
				loader.load(request);
			}
			else
			{
				// Position
				_upsellDialog.x = 462 - _upsellDialog.width / 2;
				_upsellDialog.y = 332 - _upsellDialog.height / 2;
				
				// Add as pop up.
				_roomContainer.addPopUp(_upsellDialog);
				
				// Set flag.
				_upsellIsShown = true;
			}
			
			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				
				trace('RWSLobbyController: Loaded premium upsell pop up.');
				
				_upsellDialog = loader.content as Sprite;
				_upsellDialog.filters = [new DropShadowFilter(4, 45, 0, 1, 12, 12)];
				_upsellDialog.mouseEnabled = true;
				
				// Add upsell listeners.
				_upsellDialog.addEventListener('Close', onUpsellClose);
				_upsellDialog.addEventListener('NoThanks', onUpsellNoThanks);
				_upsellDialog.addEventListener('GetMonthFree', onUpsellGetMonthFree);
				
				showUpSell();
			}
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				
				trace('RWSLobbyController: Error loading premium upsell pop up.');
			}
		}
		private function hideUpSell():void
		{
			if (_upsellIsShown != true) return;
			_upsellIsShown = false;
			_roomContainer.removePopUp(_upsellDialog);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _timerInterval(e:TimerEvent):void
		{
			_timeStep++;
			
			// Handle Trivia event countdown.
			var currentTriviaEvent:TriviaEvent = AASEventManager.getInstance().getCurrentEvent(ActionAllStarsEventType.TRIVIA_EVENT) as TriviaEvent;
			var nextTriviaEvent:TriviaEvent = AASEventManager.getInstance().getNextEvent(ActionAllStarsEventType.TRIVIA_EVENT) as TriviaEvent;
			var triviaEvent:TriviaEvent;
			var startTime:Date;
			var mTimeUntilGame:int;
			var secondsUntilGame:Number;
			
			if (currentTriviaEvent != null)
			{
				triviaEvent = currentTriviaEvent;
			}
			else if (nextTriviaEvent != null)
			{
				triviaEvent = nextTriviaEvent;
			}
			
			if (triviaEvent != null)
			{
				// Get the event start time.
				startTime = triviaEvent.startTime;
				
				// Calculate time until the trivia event starts in seconds.
				mTimeUntilGame = Math.floor(startTime.time - ModelLocator.getInstance().serverDate.time);
				secondsUntilGame = mTimeUntilGame / 1000;
				
				// Pass time until game to the background.
				Object(_triviaRoomSelectHud).secondsUntilEvent = secondsUntilGame;
				//Object(_background).secondsUntilTriviaEvent = secondsUntilGame;
			}
			
			// Handle Pickem event countdown.
			var currentPickemEvent:PickemEvent = AASEventManager.getInstance().getCurrentEvent(ActionAllStarsEventType.PICKEM_EVENT) as PickemEvent;
			var nextPickemEvent:PickemEvent = AASEventManager.getInstance().getNextEvent(ActionAllStarsEventType.PICKEM_EVENT) as PickemEvent;
			var pickemEvent:PickemEvent;
			
			if (currentPickemEvent != null)
			{
				pickemEvent = currentPickemEvent;
			}
			else if (nextPickemEvent != null)
			{
				pickemEvent = nextPickemEvent;
			}
			
			if (pickemEvent != null)
			{
				// Get the event start time.
				startTime = pickemEvent.startTime;
				
				// Calculate time until the pickem event starts in seconds.
				mTimeUntilGame = Math.floor(startTime.time - ModelLocator.getInstance().serverDate.time);
				secondsUntilGame = mTimeUntilGame / 1000;
				
				if (_timeStep == _timeStepMax) trace('RWSLobbyController: Time until pickem event: ' + secondsUntilGame);
				
				// Pass time until game to the background.
				Object(_pickemRoomSelectHud).secondsUntilEvent = secondsUntilGame;
				Object(_background).secondsUntilPickemEvent = secondsUntilGame;
			}
			
			if (_timeStep >= _timeStepMax) _timeStep = 0;
		}
		
		private function _onTriviaDoorClick(e:MouseEvent):void
		{
			//if (_triviaPopUpIsShown == false) _showTriviaRoomSelectHud();
			
			// Go to the first trivia room.
			var roomId:String = _broadcastCenterRoomIds[0];
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
		}
		
		private function _onTriviaHudClose(e:Event):void
		{
			_hideTriviaRoomSelectHud();
		}
		
		private function _onEnterRoom1(e:Event):void
		{
			// Send user to room 1.
			var roomId:String = (e.currentTarget == _triviaRoomSelectHud) ? _broadcastCenterRoomIds[0] : _pickemRoomIds[0];
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
		}
		
		private function _onEnterRoom2(e:Event):void
		{
			// Send user to room 2.
			var roomId:String = (e.currentTarget == _triviaRoomSelectHud) ? _broadcastCenterRoomIds[1] : _pickemRoomIds[1];
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
		}
		
		private function _onEnterRoom3(e:Event):void
		{
			// Send user to room 3.
			var roomId:String = (e.currentTarget == _triviaRoomSelectHud) ? _broadcastCenterRoomIds[2] : _pickemRoomIds[2];
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
		}
		
		private function _onEnterRoom4(e:Event):void
		{
			// Send user to room 4.
			var roomId:String = (e.currentTarget == _triviaRoomSelectHud) ? _broadcastCenterRoomIds[3] : _pickemRoomIds[3];
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
		}
		
		private function _onPickemDoorClick(e:MouseEvent):void
		{
			var pickemEnabled:Boolean = true;
			
			if (pickemEnabled != true) return;
			
			// Check if the user is premium.
			// If YES then let in the pickem room.
			// Otherwise, don't let them in.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			
			// Premium Requirement Removed
			var roomId:String = _pickemRoomIds[0];
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			
		}
		
		private function _onPickemHudClose(e:Event):void
		{
			_hidePickemRoomSelectHud();
		}
		
		private function onUpsellClose(e:Event):void
		{
			// Hide the upsell dialog.
			hideUpSell();
		}
		
		private function onUpsellNoThanks(e:Event):void
		{
			// Hide the upsell dialog.
			hideUpSell();
		}
		
		private function onUpsellGetMonthFree(e:Event):void
		{
			// Determine membership status.
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			if (userAvatar.membershipStatus ==  Constants.MEMBER_STATUS_GUEST)
			{
				// Send to registration.
				MainUtil.postAvatarIdToURL('register.jsp', ModelLocator.getInstance().avatar.id, 10);
			}
			else
			{
				// Send user to the premium sign up page.
				//MainUtil.postAvatarIdToURL('membership.jsp', ModelLocator.getInstance().avatar.id, 10);
				navigateToURL(new URLRequest('http://' + Environment.returnUrl +
						'/premium/co/ccard?userId=' + ModelLocator.getInstance().user.userId +
						'&pm=' + Constants.CREDIT_CARD + '&plan=' + 7 + '&mf=1&affiliateId=' + ModelLocator.getInstance().affiliate), '_self');
			}
		}
	}
}